/* chat-window.vala
 *
 * Copyright 2026 PORQUET Sébastien
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using Adw;
using Gtk;
using Gee;
using Json;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Providers.Twitch;

namespace StreamlinkGtk.Widgets.Providers.Twitch {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/plugins/providers/twitch/widgets/chat-window.ui")]
    public class ChatWindow : Adw.Window, IChatWindow {

        [GtkChild]
        private unowned ListBox chat_list;
        [GtkChild]
        private unowned Entry chat_entry;
        [GtkChild]
        private unowned Button send_button;
        [GtkChild]
        private unowned Adw.WindowTitle window_title;
        [GtkChild]
        private unowned ScrolledWindow scrolled_window;
        [GtkChild]
        private unowned ListBox users_list;
        [GtkChild]
        private unowned Adw.Flap flap;

        private Soup.Session session;
        private Soup.Session api_session;
        private Soup.WebsocketConnection ws_conn;
        private string channel_name;
        private string twitch_oauth;
        private string twitch_username;
        private string? channel_id;
        private Gee.HashMap<string, string> badge_cache;
        private Json.Parser json_parser;

        private class EmoteReplacement {
            public int start;
            public int end;
            public string url;
        }

        private Gee.TreeSet<string> connected_users;
        private Gee.TreeSet<string> users_fetching_avatar;
        private Gee.TreeSet<string> avatar_fetched;
        private Gee.HashMap<string, Gdk.Texture> avatar_texture_cache;

        public ChatWindow (string channel_name) {
            GLib.Object ();
            this.channel_name = channel_name.down ();
            this.badge_cache = new Gee.HashMap<string, string> ();
            this.json_parser = new Json.Parser ();
            this.connected_users = new Gee.TreeSet<string> ();
            this.users_fetching_avatar = new Gee.TreeSet<string> ();
            this.avatar_fetched = new Gee.TreeSet<string> ();
            this.avatar_texture_cache = new Gee.HashMap<string, Gdk.Texture> ();

            StreamlinkGtk.Settings.AppSettings app_settings = StreamlinkGtk.Settings.AppSettings.get_default ();
            this.twitch_username = app_settings.provider_user.username;

            GLib.Settings twitch_settings = new GLib.Settings ("org.gnome.gstreamlink.plugins.providers.twitch");
            this.twitch_oauth = twitch_settings.get_string ("website-oauth");
            this.window_title.subtitle = channel_name;

            this.chat_entry.activate.connect (this.on_send_clicked);
            this.send_button.clicked.connect (this.on_send_clicked);

            this.add_message ("System", "Connecting to chat for " + channel_name + "...", "");

            this.session = new Soup.Session ();
            this.api_session = new Soup.Session ();
            this.fetch_badges_async.begin ();
            this.connect_to_twitch_chat ();

            this.flap.notify["reveal-flap"].connect (() => {
                if (this.flap.reveal_flap) {
                    this.update_users_list ();
                }
            });
        }

        private async void fetch_badges_async () {
            StreamlinkGtk.Settings.AppSettings app_settings = StreamlinkGtk.Settings.AppSettings.get_default ();
            string auth_token = app_settings.provider_user.bearer_token;
            if (auth_token == null || auth_token == "")return;

            // Get user ID for channel
            Soup.Message msg_user = new Soup.Message ("GET", StreamlinkGtk.Providers.Twitch.Twitch.api_base_url + "/users?login=" + this.channel_name);
            msg_user.request_headers.append ("Authorization", "Bearer " + auth_token);
            msg_user.request_headers.append ("Client-Id", StreamlinkGtk.Providers.Twitch.Twitch.app_client_id);
            try {
                GLib.Bytes bytes_user = yield this.api_session.send_and_read_async (msg_user, GLib.Priority.DEFAULT, null);

                if (bytes_user != null && bytes_user.length > 0) {
                    string data = (string) bytes_user.get_data ();
                    if (this.json_parser.load_from_data (data)) {
                        Json.Node root = this.json_parser.get_root ();
                        if (root != null && root.get_node_type () == Json.NodeType.OBJECT) {
                            Json.Array data_arr = root.get_object ().get_array_member ("data");
                            if (data_arr != null && data_arr.get_length () > 0) {
                                this.channel_id = data_arr.get_element (0).get_object ().get_string_member ("id");
                            }
                        }
                    }
                }
            } catch (Error e) {
                warning ("Failed to get channel id: %s", e.message);
            }

            // Get global badges
            Soup.Message msg_global = new Soup.Message ("GET", StreamlinkGtk.Providers.Twitch.Twitch.api_base_url + "/chat/badges/global");
            msg_global.request_headers.append ("Authorization", "Bearer " + auth_token);
            msg_global.request_headers.append ("Client-Id", StreamlinkGtk.Providers.Twitch.Twitch.app_client_id);
            try {
                GLib.Bytes bytes_global = yield this.api_session.send_and_read_async (msg_global, GLib.Priority.DEFAULT, null);

                if (bytes_global != null && bytes_global.length > 0) {
                    this.parse_badges_response ((string) bytes_global.get_data ());
                }
            } catch (Error e) {
                warning ("Failed to get global badges: %s", e.message);
            }

            // Get channel badges
            if (this.channel_id != null) {
                Soup.Message msg_channel = new Soup.Message ("GET", StreamlinkGtk.Providers.Twitch.Twitch.api_base_url + "/chat/badges?broadcaster_id=" + this.channel_id);
                msg_channel.request_headers.append ("Authorization", "Bearer " + auth_token);
                msg_channel.request_headers.append ("Client-Id", StreamlinkGtk.Providers.Twitch.Twitch.app_client_id);
                try {
                    GLib.Bytes bytes_channel = yield this.api_session.send_and_read_async (msg_channel, GLib.Priority.DEFAULT, null);

                    if (bytes_channel != null && bytes_channel.length > 0) {
                        this.parse_badges_response ((string) bytes_channel.get_data ());
                    }
                } catch (Error e) {
                    warning ("Failed to get channel badges: %s", e.message);
                }
            }
        }

        private void parse_badges_response (string data) {
            try {
                if (this.json_parser.load_from_data (data)) {
                    Json.Node root = this.json_parser.get_root ();
                    if (root != null && root.get_node_type () == Json.NodeType.OBJECT) {
                        Json.Array data_arr = root.get_object ().get_array_member ("data");
                        if (data_arr != null) {
                            foreach (Json.Node set_node in data_arr.get_elements ()) {
                                string set_id = set_node.get_object ().get_string_member ("set_id");
                                Json.Array versions = set_node.get_object ().get_array_member ("versions");
                                if (versions != null) {
                                    foreach (Json.Node version_node in versions.get_elements ()) {
                                        string version_id = version_node.get_object ().get_string_member ("id");
                                        string image_url_1x = version_node.get_object ().get_string_member ("image_url_1x");
                                        this.badge_cache.set (set_id + "/" + version_id, image_url_1x);
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (Error e) {
                warning ("Failed to parse badges: %s", e.message);
            }
        }

        private void load_image_to_picture (Gtk.Picture picture, string url) {
            Soup.Message msg = new Soup.Message ("GET", url);
            this.api_session.send_and_read_async.begin (msg, GLib.Priority.DEFAULT, null, (obj, res) => {
                try {
                    GLib.Bytes bytes = this.api_session.send_and_read_async.end (res);
                    if (msg.status_code == 200 && bytes != null && bytes.length > 0) {
                        var texture = Gdk.Texture.from_bytes (bytes);
                        picture.set_paintable (texture);
                    }
                } catch (Error e) {
                    warning ("Failed to load image from %s: %s", url, e.message);
                }
            });
        }

        private void connect_to_twitch_chat () {
            Soup.Message msg = new Soup.Message ("GET", "wss://irc-ws.chat.twitch.tv:443");
            this.session.websocket_connect_async.begin (msg, null, null, GLib.Priority.DEFAULT, null, (obj, res) => {
                try {
                    this.ws_conn = this.session.websocket_connect_async.end (res);
                    this.ws_conn.message.connect (this.on_ws_message);
                    this.ws_conn.closed.connect (() => {
                        this.add_message ("System", "Disconnected from chat.", "");
                    });

                    this.ws_conn.send_text ("CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership\r\n");

                    if (this.twitch_oauth != null && this.twitch_oauth != "" && this.twitch_username != null && this.twitch_username != "") {
                        string pass = this.twitch_oauth;
                        if (!pass.has_prefix ("oauth:")) {
                            pass = "oauth:" + pass;
                        }
                        this.ws_conn.send_text ("PASS " + pass + "\r\n");
                        this.ws_conn.send_text ("NICK " + this.twitch_username.down () + "\r\n");
                    } else {
                        this.ws_conn.send_text ("PASS SCHMOOPIIE\r\n");
                        int random_id = GLib.Random.int_range (10000, 99999);
                        this.ws_conn.send_text ("NICK justinfan" + random_id.to_string () + "\r\n");
                    }
                    this.ws_conn.send_text ("JOIN #" + this.channel_name + "\r\n");
                } catch (Error e) {
                    this.add_message ("System", "Failed to connect: " + e.message, "");
                }
            });
        }

        private void on_ws_message (int type, GLib.Bytes message) {
            if (type != Soup.WebsocketDataType.TEXT)return;
            unowned uint8[] data = message.get_data ();
            if (data == null || data.length == 0)return;

            StringBuilder sb = new StringBuilder ();
            sb.append_len ((string) data, data.length);
            string text = sb.str;

            string[] lines = text.split ("\r\n");
            foreach (string line in lines) {
                if (line == "")continue;

                if (line.has_prefix ("PING")) {
                    this.ws_conn.send_text (line.replace ("PING", "PONG") + "\r\n");
                    continue;
                }

                if (line.contains (" JOIN #")) {
                    int excl_idx = line.index_of ("!");
                    if (excl_idx != -1 && line.has_prefix (":")) {
                        string user = line.substring (1, excl_idx - 1);
                        if (this.connected_users.add (user)) {
                            this.update_users_list ();
                        }
                    }
                    continue;
                }

                if (line.contains (" PART #")) {
                    int excl_idx = line.index_of ("!");
                    if (excl_idx != -1 && line.has_prefix (":")) {
                        string user = line.substring (1, excl_idx - 1);
                        if (this.connected_users.remove (user)) {
                            this.update_users_list ();
                        }
                    }
                    continue;
                }

                // 353 is RPL_NAMREPLY
                if (line.contains (" 353 ")) {
                    int colon_idx = line.index_of (":", line.index_of (" 353 ") + 5);
                    if (colon_idx != -1) {
                        string names_str = line.substring (colon_idx + 1);
                        string[] names = names_str.split (" ");
                        bool added = false;
                        foreach (string name in names) {
                            if (name != "") {
                                if (this.connected_users.add (name)) {
                                    added = true;
                                }
                            }
                        }
                        if (added) {
                            this.update_users_list ();
                        }
                    }
                    continue;
                }

                if (line.contains (" 001 ")) {
                    this.add_message ("System", "Connected to chat successfully!", "");
                    continue;
                }

                if (line.contains (" NOTICE ")) {
                    int colon_idx = line.index_of (":", line.index_of (" NOTICE ") + 8);
                    if (colon_idx != -1) {
                        this.add_message ("System", line.substring (colon_idx + 1), "red");
                    }
                    continue;
                }

                if (line.contains (" PRIVMSG #")) {
                    string author = "Unknown";
                    string msg_text = "";
                    string color = "";
                    string emotes_str = "";
                    string badges_str = "";

                    if (line.has_prefix ("@")) {
                        int space_idx = line.index_of (" ");
                        if (space_idx != -1) {
                            string tags_str = line.substring (1, space_idx - 1);
                            string[] tags = tags_str.split (";");
                            foreach (string tag in tags) {
                                if (tag.has_prefix ("display-name=")) {
                                    author = tag.substring (13);
                                } else if (tag.has_prefix ("color=")) {
                                    color = tag.substring (6);
                                } else if (tag.has_prefix ("emotes=")) {
                                    emotes_str = tag.substring (7);
                                } else if (tag.has_prefix ("badges=")) {
                                    badges_str = tag.substring (7);
                                }
                            }
                        }
                    } else {
                        // fallback if no tags
                        int excl_idx = line.index_of ("!");
                        if (excl_idx != -1 && line.has_prefix (":")) {
                            author = line.substring (1, excl_idx - 1);
                        }
                    }

                    int privmsg_idx = line.index_of (" PRIVMSG #");
                    if (privmsg_idx != -1) {
                        int colon_idx = line.index_of (":", privmsg_idx + 10);
                        if (colon_idx != -1) {
                            msg_text = line.substring (colon_idx + 1);
                        }
                    }

                    if (msg_text != "") {
                        this.add_message (author, msg_text, color, badges_str, emotes_str);
                    }
                }
            }
        }

        private uint update_users_list_timeout_id = 0;

        private void update_users_list () {
            if (!this.flap.reveal_flap) {
                return;
            }

            if (this.update_users_list_timeout_id != 0) {
                return;
            }
            this.update_users_list_timeout_id = GLib.Timeout.add (500, () => {
                this.update_users_list_timeout_id = 0;

                // Clear existing
                while (true) {
                    Gtk.Widget? child = this.users_list.get_first_child ();
                    if (child == null)break;
                    this.users_list.remove (child);
                }

                bool missing_avatars = false;

                foreach (string user in this.connected_users) {
                    Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
                    box.margin_start = 12;
                    box.margin_end = 12;
                    box.margin_top = 6;
                    box.margin_bottom = 6;

                    Gtk.Stack stack = new Gtk.Stack ();
                    stack.valign = Gtk.Align.CENTER;

                    Gtk.Spinner spinner = new Gtk.Spinner ();
                    spinner.width_request = 24;
                    spinner.height_request = 24;
                    spinner.spinning = true;
                    stack.add_named (spinner, "spinner");

                    Adw.Avatar avatar = new Adw.Avatar (24, user, true);
                    stack.add_named (avatar, "avatar");

                    if (this.avatar_fetched.contains (user)) {
                        if (this.avatar_texture_cache.has_key (user)) {
                            avatar.custom_image = this.avatar_texture_cache.get (user);
                        }
                        stack.visible_child_name = "avatar";
                    } else {
                        missing_avatars = true;
                        stack.visible_child_name = "spinner";
                    }

                    Gtk.Label label = new Gtk.Label (user);
                    label.halign = Gtk.Align.START;
                    label.valign = Gtk.Align.CENTER;

                    box.append (stack);
                    box.append (label);

                    this.users_list.append (box);
                }

                if (missing_avatars) {
                    this.fetch_missing_avatars_async.begin ();
                }

                return false;
            });
        }

        private async void fetch_missing_avatars_async () {
            StreamlinkGtk.Settings.AppSettings app_settings = StreamlinkGtk.Settings.AppSettings.get_default ();
            string auth_token = app_settings.provider_user.bearer_token;
            if (auth_token == null || auth_token == "")return;

            Gee.ArrayList<string> missing = new Gee.ArrayList<string> ();
            foreach (string user in this.connected_users) {
                if (!this.avatar_texture_cache.has_key (user) && !this.users_fetching_avatar.contains (user)) {
                    missing.add (user);
                    if (missing.size == 100)break;
                }
            }

            if (missing.is_empty)return;

            foreach (string user in missing) {
                this.users_fetching_avatar.add (user);
            }

            string uri = StreamlinkGtk.Providers.Twitch.Twitch.api_base_url + "/users?";
            bool first = true;
            foreach (string user in missing) {
                if (!first)uri += "&";
                uri += "login=" + user;
                first = false;
            }

            Soup.Message msg = new Soup.Message ("GET", uri);
            msg.request_headers.append ("Authorization", "Bearer " + auth_token);
            msg.request_headers.append ("Client-Id", StreamlinkGtk.Providers.Twitch.Twitch.app_client_id);

            Gee.ArrayList<string> users_with_avatars = new Gee.ArrayList<string> ();

            try {
                GLib.Bytes bytes = yield this.api_session.send_and_read_async (msg, GLib.Priority.DEFAULT, null);

                if (bytes != null && bytes.length > 0) {
                    string data = (string) bytes.get_data ();
                    if (this.json_parser.load_from_data (data)) {
                        Json.Node root = this.json_parser.get_root ();
                        if (root != null && root.get_node_type () == Json.NodeType.OBJECT) {
                            Json.Array data_arr = root.get_object ().get_array_member ("data");
                            if (data_arr != null) {
                                foreach (Json.Node user_node in data_arr.get_elements ()) {
                                    string login = user_node.get_object ().get_string_member ("login");
                                    string profile_image_url = user_node.get_object ().get_string_member ("profile_image_url");
                                    users_with_avatars.add (login);
                                    this.load_avatar_texture_async.begin (login, profile_image_url);
                                }
                            }
                        }
                    }
                }
                // For users missing from response
                foreach (string user in missing) {
                    if (!users_with_avatars.contains (user)) {
                        this.users_fetching_avatar.remove (user);
                        this.avatar_fetched.add (user);
                        this.apply_avatar_to_ui (user);
                    }
                }
            } catch (Error e) {
                warning ("Failed to fetch avatars: %s", e.message);
                foreach (string user in missing) {
                    this.users_fetching_avatar.remove (user);
                    this.avatar_fetched.add (user);
                    this.apply_avatar_to_ui (user);
                }
            }
        }

        private async void load_avatar_texture_async (string login, string url) {
            Soup.Message msg = new Soup.Message ("GET", url);
            try {
                GLib.Bytes bytes = yield this.api_session.send_and_read_async (msg, GLib.Priority.DEFAULT, null);

                if (msg.status_code == 200 && bytes != null && bytes.length > 0) {
                    var texture = Gdk.Texture.from_bytes (bytes);
                    this.avatar_texture_cache.set (login, texture);
                }
            } catch (Error e) {
                warning ("Failed to load avatar for %s: %s", login, e.message);
            }
            this.users_fetching_avatar.remove (login);
            this.avatar_fetched.add (login);
            this.apply_avatar_to_ui (login);
        }

        private void apply_avatar_to_ui (string login) {
            Gtk.Widget? child = this.users_list.get_first_child ();
            while (child != null) {
                Gtk.ListBoxRow? row = child as Gtk.ListBoxRow;
                if (row != null) {
                    Gtk.Box? box = row.get_child () as Gtk.Box;
                    if (box != null) {
                        Gtk.Stack? stack = box.get_first_child () as Gtk.Stack;
                        Gtk.Label? label = box.get_last_child () as Gtk.Label;
                        if (label != null && label.label == login && stack != null) {
                            if (this.avatar_texture_cache.has_key (login)) {
                                Adw.Avatar? avatar = stack.get_child_by_name ("avatar") as Adw.Avatar;
                                if (avatar != null) {
                                    avatar.custom_image = this.avatar_texture_cache.get (login);
                                }
                            }
                            stack.visible_child_name = "avatar";
                            break;
                        }
                    }
                }
                child = child.get_next_sibling ();
            }
        }

        private void on_send_clicked () {
            string text = this.chat_entry.text;
            if (text != "") {
                if (this.twitch_oauth != null && this.twitch_oauth != "" && this.twitch_username != null && this.twitch_username != "") {
                    this.ws_conn.send_text ("PRIVMSG #" + this.channel_name + " :" + text + "\r\n");
                    this.add_message (this.twitch_username, text, "");
                } else {
                    this.add_message ("System", "You must be logged in to Twitch to send messages.", "red");
                }
                this.chat_entry.text = "";
            }
        }

        public void add_message (string author, string text, string color = "", string badges_str = "", string emotes_str = "") {
            Gtk.TextBuffer buffer = new Gtk.TextBuffer (null);
            Gtk.TextView text_view = new Gtk.TextView.with_buffer (buffer);
            text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
            text_view.editable = false;
            text_view.cursor_visible = false;
            text_view.can_focus = false;
            text_view.margin_start = 6;
            text_view.margin_end = 6;
            text_view.margin_top = 3;
            text_view.margin_bottom = 3;

            Gtk.TextIter iter;
            buffer.get_start_iter (out iter);

            // Add badges
            if (badges_str != "") {
                string[] badges = badges_str.split (",");
                foreach (string badge in badges) {
                    if (this.badge_cache.has_key (badge)) {
                        string url = this.badge_cache.get (badge);
                        Gtk.TextChildAnchor anchor = buffer.create_child_anchor (iter);
                        Gtk.Picture pic = new Gtk.Picture ();
                        pic.valign = Gtk.Align.CENTER;
                        pic.margin_end = 4;
                        pic.width_request = 18;
                        pic.height_request = 18;
                        this.load_image_to_picture (pic, url);
                        text_view.add_child_at_anchor (pic, anchor);
                        buffer.get_end_iter (out iter);
                    }
                }
            }

            // Add author name
            Gtk.TextTag author_tag = new Gtk.TextTag ("author");
            author_tag.weight = Pango.Weight.BOLD;
            if (color != "") {
                author_tag.foreground = color;
            }
            buffer.tag_table.add (author_tag);

            Gtk.TextMark author_start_mark = buffer.create_mark (null, iter, true);
            buffer.insert (ref iter, author + ": ", -1);

            Gtk.TextIter author_start_iter;
            buffer.get_iter_at_mark (out author_start_iter, author_start_mark);
            buffer.apply_tag (author_tag, author_start_iter, iter);
            buffer.delete_mark (author_start_mark);

            // Keep track of text start offset for emote replacements
            int text_start_offset = iter.get_offset ();
            buffer.insert (ref iter, text, -1);

            // Handle emotes
            if (emotes_str != "") {
                var replacements = new Gee.ArrayList<EmoteReplacement?> ();

                string[] emotes = emotes_str.split ("/");
                foreach (string emote in emotes) {
                    string[] parts = emote.split (":");
                    if (parts.length == 2) {
                        string emote_id = parts[0];
                        string url = "https://static-cdn.jtvnw.net/emoticons/v2/" + emote_id + "/static/dark/1.0";
                        string[] ranges = parts[1].split (",");
                        foreach (string range in ranges) {
                            string[] bounds = range.split ("-");
                            if (bounds.length == 2) {
                                EmoteReplacement repl = new EmoteReplacement ();
                                repl.start = int.parse (bounds[0]);
                                repl.end = int.parse (bounds[1]);
                                repl.url = url;
                                replacements.add (repl);
                            }
                        }
                    }
                }

                replacements.sort ((a, b) => {
                    return b.start - a.start; // descending
                });

                foreach (EmoteReplacement repl in replacements) {
                    Gtk.TextIter start_iter;
                    buffer.get_iter_at_offset (out start_iter, text_start_offset + repl.start);
                    Gtk.TextIter end_iter;
                    buffer.get_iter_at_offset (out end_iter, text_start_offset + repl.end + 1);

                    buffer.delete (ref start_iter, ref end_iter);

                    Gtk.TextChildAnchor anchor = buffer.create_child_anchor (start_iter);
                    Gtk.Picture pic = new Gtk.Picture ();
                    pic.valign = Gtk.Align.CENTER;
                    pic.margin_start = 2;
                    pic.margin_end = 2;
                    pic.width_request = 28;
                    pic.height_request = 28;
                    this.load_image_to_picture (pic, repl.url);
                    text_view.add_child_at_anchor (pic, anchor);
                }
            }

            ListBoxRow row = new ListBoxRow ();
            row.child = text_view;
            row.selectable = false;

            this.chat_list.append (row);

            Adjustment adj = this.scrolled_window.vadjustment;
            if (adj != null) {
                GLib.Idle.add (() => {
                    adj.value = adj.upper - adj.page_size;
                    return false;
                });
            }
        }
    }
}