/* twitch.vala
 *
 * Copyright 2025 PORQUET Sébastien
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
using GLib;
using Gtk;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models;
using StreamlinkGtk.Models.Providers;
using StreamlinkGtk.Providers.Twitch.Models;
using StreamlinkGtk.Services;
using StreamlinkGtk.Widgets.Providers.Default;
using StreamlinkGtk.Widgets.Providers.Twitch;

namespace StreamlinkGtk.Providers.Twitch {

    public errordomain TwitchError {
        INVALID_FORMAT,
        INVALID_USER
    }

    class Twitch : Object, IProviderPlugin {

        public uint id { get; default = 1; }
        public string name { get; default = "Twitch"; }
        public bool user_login_available { get; default = true; }
        public bool user_login_mandatory { get;  default = true; }
        public ProviderUser? provider_user { get; set; }
        public string authorize_url { get;   set; }
        public string redirect_uri { get;   default = "http://localhost:3000"; }
        public IScrolledWindowContents scrolled_window_contents { get; set; }
        public Adw.PreferencesPage preferences_page { get; set; }
        public uint auto_refresh_interval { get; }
        public bool enable_notifications { get; }

        public ProviderPluginLoader provider_plugin_loader { get; set; }


        private TwitchSettings store;
        private Cache cache;
        private ApiRequest api_request;
        private Json.Parser json_parser;
        private string base_url = "https://www.twitch.tv";
        private string api_base_url = "https://api.twitch.tv/helix";
        // Used for OAuth authentication.
        private string app_client_id = "nphupig00csx42och5rum6s1gang4z";

        private string authorize_state  {
            owned get {
                return Uuid.string_random ();
            }
        }

        // twitch default: 440x248
        // 440 -> 100.00 %<d
        // 310     70.45 %
        // 248 -> 100.00 %
        // 175     70.45 %
        private int thumbnail_width = 310;
        private int thumbnail_height = 175;

        construct {

            this.authorize_url = "https://id.twitch.tv/oauth2/authorize?scope=user%3Aread%3Afollows&response_type=token&client_id=" + this.app_client_id + "&redirect_uri=" + this.redirect_uri + "&state=" + this.authorize_state;
            this.json_parser = new Json.Parser ();

            this.store = TwitchSettings.get_default ();
            this.cache = Cache.get_default ();
            this.scrolled_window_contents = new ScrolledWindowContents ();
            this.preferences_page = new StreamlinkGtk.Widgets.Providers.Twitch.PreferencesPage ();
        }

        public Twitch (IScrolledWindowContents scrolled_window_contents) {
            Object (scrolled_window_contents : scrolled_window_contents);
        }

        public void registered (ProviderPluginLoader provider_plugin_loader) {
            this.provider_plugin_loader = provider_plugin_loader;
        }

        public void activate () {
            debug ("Provider plugin - Twitch - activate\n");
        }

        public void deactivate () {
            debug ("Provider plugin - Twitch - deactivate");
        }

        public string get_extra_args_for_streaming_provider (IStreamingProviderPlugin streaming_provider) {

            Variant variant = this.store.get_value ("website-oauth");
            string extra_args = "";
            string website_oauth = variant.get_string ();

            switch (streaming_provider.name) {

            case "Streamlink":
                if (website_oauth != "") {
                    extra_args += "--twitch-api-header=Authorization=OAuth " + website_oauth;
                }
                break;

            default:
                debug ("Streaming provider not handled: %s", streaming_provider.name);
                break;
            }

            return extra_args;
        }

        public void initialize_api_request () {

            this.api_request = new ApiRequest (this.api_base_url);
            this.api_request.default_request_headers.append (new RequestHeader ("Authorization", "Bearer " + this.provider_user.bearer_token));
            this.api_request.default_request_headers.append (new RequestHeader ("Client-Id", this.app_client_id));

            this.api_request.got_error.connect ((error_code, error_message) => {

                Toast toast = new Toast (error_message);
                toast.set_button_label ("re login");
                toast.button_clicked.connect (() => {
                    this.make_oauth_login ();
                });

                this.got_api_error (toast);
            });
        }

        public async bool update_provider_user_info_async (ProviderUser provider_user) {

            Response response = yield this.get_response_async (ApiEndPoint.USERS);

            if (response.data == null) {
                return false;
            }

            debug ("[twitch] got user info.");
            ///We asked for one user, so there's only one result.
            provider_user.id = response.data.get_element (0).get_object ().get_string_member ("id");
            provider_user.username = response.data.get_element (0).get_object ().get_string_member ("login");

            return true;
        }

        public async void get_side_bar_list_box_rows_async (out Array<ISideBarListBoxRow> list_box_rows) {

            list_box_rows = new Array<ISideBarListBoxRow> ();

            SideBarListBoxRow list_box_row_follows = new SideBarListBoxRow ("Follows", false, new ContentsSelector (0, null));
            list_box_rows.append_val (list_box_row_follows);

            SideBarListBoxRow list_box_row_followed_stream = new SideBarListBoxRow ("Streams", true, new ContentsSelector (ContentsId.STREAMS_FOLLOWED, null));
            list_box_rows.append_val (list_box_row_followed_stream);

            SideBarListBoxRow list_box_row_followed_channels = new SideBarListBoxRow ("Channels", true, new ContentsSelector (ContentsId.CHANNELS_FOLLOWED, null));
            list_box_rows.append_val (list_box_row_followed_channels);

            SideBarListBoxRow list_box_row_browse = new SideBarListBoxRow ("Browse", false, new ContentsSelector (0, null));
            list_box_rows.append_val (list_box_row_browse);

            SideBarListBoxRow list_box_row_games = new SideBarListBoxRow ("Games", true, new ContentsSelector (ContentsId.GAMES, null));
            list_box_rows.append_val (list_box_row_games);

            SideBarListBoxRow list_box_row_streams = new SideBarListBoxRow ("Streams", true, new ContentsSelector (ContentsId.STREAMS, null));
            list_box_rows.append_val (list_box_row_streams);
        }

        public async void get_contents_async (ContentsSelector contents_selector, out Contents contents) {

            switch (contents_selector.contents_id) {

            case ContentsId.CHANNELS_FOLLOWED:

                contents = yield this.get_contents_channels_followed_async ();

                break;

            case ContentsId.STREAMS:

                contents = yield this.get_contents_streams_async ();

                break;

            case ContentsId.STREAMS_FOLLOWED:

                contents = yield this.get_contents_stream_followed_async ();

                break;



            case ContentsId.VIDEOS:

                contents = yield this.get_contents_videos_async (contents_selector);

                break;

            default:
                contents = new Contents (0, "No contents");
                warning ("[twitch] contents ID  %u  not handled.", contents_selector.contents_id);
                return;
            }

            this.got_contents ();
        }

        public async void get_next_contents_async () {


            switch (this.scrolled_window_contents.contents.contents_id) {

            case ContentsId.STREAMS:

                yield this.get_resource_streams_async (ApiEndPoint.STREAMS, this.scrolled_window_contents.contents);

                break;

            case ContentsId.STREAMS_FOLLOWED:

                yield this.get_resource_streams_async (ApiEndPoint.STREAM_FOLLOWED, this.scrolled_window_contents.contents);

                break;

            case ContentsId.VIDEOS:

                yield this.get_resource_videos_async (ApiEndPoint.VIDEOS, this.scrolled_window_contents.contents);

                break;

            default:
                warning ("Contents ID [ %u ]  not handled.", this.scrolled_window_contents.contents.contents_id);
                return;
            }

            this.got_contents ();
        }

        /**
         * For now, it's just to display a notification when a new streame is online.
         */
        public async void perform_async_tasks () {

            if (this.store.get_boolean ("enable-notifications") == false) {

                return;
            }

            DateTime current_time = new DateTime.now ();
            DateTime previous_run = new DateTime.from_iso8601 (this.store.get_string ("last-async-execution-time"), new GLib.TimeZone.local ());

            int64 difference_microseconds = current_time.difference (previous_run);
            int64 difference_minutes = difference_microseconds / 60000000;

            if (difference_minutes < this.store.get_uint  ("refresh-interval")) {

                return;
            }

            // @todo should check if we need to check if user is logged here.
            Contents streams_contents = yield this.get_contents_stream_followed_async ();

            string[] current_stream_ids = streams_contents.get_resource_ids ().to_array ();
            string[] previous_stream_ids = this.store.get_strv ("last-live-stream-ids");

            foreach (StreamlinkGtk.Models.Resource resource in streams_contents.resources) {

                bool is_new_stream = true;
                if (previous_stream_ids.length > 0) {

                    foreach (var previous_stream_id in previous_stream_ids) {

                        if (previous_stream_id == resource.id) {

                            is_new_stream = false;
                            break;
                        }
                    }
                }

                if (is_new_stream == true) {

                    Notification notification = new Notification (resource.title + " is live !");
                    notification.set_body ((resource as StreamlinkGtk.Models.ResourceStream).viewers_count.to_string () + " viewers, since " + (resource as StreamlinkGtk.Models.ResourceStream).elapsed_time.to_string ());

                    File icon_file = File.new_for_path (this.cache.thumbnails_channels_cache_dir + "/twitch_" + resource.title + ".jpg");
                    notification.set_icon (new FileIcon (icon_file));

                    notification.set_priority (NotificationPriority.NORMAL);
                    this.notification (resource.id, notification);
                }
            }

            this.store.set_value ("last-live-stream-ids", current_stream_ids);
            this.store.set_string ("last-async-execution-time", current_time.to_string ());
        }

        /*
         *
         * CHANNELS
         *
         */
        private async Contents get_contents_channels_followed_async () {

            Contents contents = new Contents (ContentsId.CHANNELS_FOLLOWED, "Followed channels");

            // First, get the broadcaster followed.
            Array<string> broadcaster_ids;

            bool result = yield this.get_channels_followed_async (ApiEndPoint.CHANNELS_FOLLOWED + "?first=50&user_id=" + this.provider_user.id, contents, out broadcaster_ids);

            if (result == false) {

                return contents;
            }

            // Second, get channels info.
            //
            // We user /users end-point to get broadcaster offline image.
            // broadcaster_id = user_id (id)
            string uri_params = "";
            foreach (string broadcaster_id in broadcaster_ids) {

                uri_params += "&id=" + broadcaster_id;
            }
            uri_params = uri_params.substring (1, uri_params.length - 1);

            yield this.get_resource_users_async (ApiEndPoint.USERS + "?" + uri_params, contents);

            return contents;
        }

        private async bool get_channels_followed_async (string uri, Contents contents, out Array<string> broadcaster_ids) {

            broadcaster_ids = new Array<string> ();

            Response response = yield this.get_response_async (uri, contents);

            if (response.data == null) {
                return false;
            }

            foreach (unowned Json.Node stream_data in response.data.get_elements ()) {

                broadcaster_ids.append_val (stream_data.get_object ().get_member ("broadcaster_id").get_string ());
            }

            return true;
        }

        private async bool get_resource_users_async (string uri, Contents contents) {

            Response response = yield this.get_response_async (uri, contents);

            if (response.data == null) {
                return false;
            }

            foreach (unowned Json.Node stream_data in response.data.get_elements ()) {

                string user_id = stream_data.get_object ().get_member ("id").get_string ();

                string display_name = stream_data.get_object ().get_member ("display_name").get_string ();

                string thumbnail_url = stream_data.get_object ().get_member ("profile_image_url").get_string ();

                string thumbnail_path = this.cache.thumbnails_channels_cache_dir + "/twitch_" + display_name + ".jpg";

                // 604800s - 1 week cache because why not.
                Thumbnail thumbnail = new Thumbnail (150, 150, thumbnail_url, thumbnail_path, 604800);

                string content_url = this.base_url + "/" + display_name;
                StreamlinkGtk.Models.Resource resource = new ResourceChannel (
                                                                              display_name,
                                                                              thumbnail,
                                                                              content_url);

                Array<string> css_classes = new Array<string> ();
                css_classes.append_val ("title-3");

                resource.title_css_classes = css_classes;

                resource.is_contents_selector = true;
                Gee.HashMap<string, string> parameters = new Gee.HashMap<string, string> ();
                parameters.set ("user_id", user_id);

                resource.contents_selector = new ContentsSelector (ContentsId.VIDEOS, parameters);
                contents.resources.append_val (resource);

                // If we got a cursor, we just update the current scrolled window's grid view model.
                if (contents.pagination_cursor.valid == true) {

                    this.scrolled_window_contents.list_store.append (resource);
                }
            }

            contents.pagination_cursor = response.pagination_cursor;

            return true;
        }

        /*
         *
         * STREAMS
         *
         */
        private async Contents get_contents_streams_async () {

            Contents contents = new Contents (ContentsId.STREAMS, "Live streams");

            yield this.get_resource_streams_async (ApiEndPoint.STREAMS, contents);

            return contents;
        }

        private async Contents get_contents_stream_followed_async () {

            Contents contents = new Contents (ContentsId.STREAMS_FOLLOWED, "Followed streams");

            yield this.get_resource_streams_async (ApiEndPoint.STREAM_FOLLOWED + "?user_id=" + this.provider_user.id, contents);

            return contents;
        }

        private async bool get_resource_streams_async (string uri, Contents contents) {

            Response response = yield this.get_response_async (uri, contents);

            if (response.data == null) {
                return false;
            }

            foreach (unowned Json.Node stream_data in response.data.get_elements ()) {

                string title = stream_data.get_object ().get_member ("user_name").get_string ();

                string subtitle = stream_data.get_object ().get_member ("title").get_string ();


                string thumbnail_url = stream_data.get_object ().get_member ("thumbnail_url").get_string ();
                thumbnail_url = thumbnail_url.replace ("{width}", this.thumbnail_width.to_string ()).replace ("{height}", this.thumbnail_height.to_string ()).to_string ();

                string thumbnail_path = this.cache.thumbnails_streams_cache_dir + "/twitch_" + title + ".jpg";

                string started_at_str = stream_data.get_object ().get_member ("started_at").get_string ();
                started_at_str.replace ("Z", "");
                DateTime started_at = new DateTime.from_iso8601 (started_at_str, new TimeZone.local ());

                int num_viewers = (int) stream_data.get_object ().get_member ("viewer_count").get_int ();

                // thumbnails refreshed every 5m (300s)
                Thumbnail thumbnail = new Thumbnail (this.thumbnail_width, this.thumbnail_height, thumbnail_url, thumbnail_path, 300);

                string content_url = this.base_url + "/" + stream_data.get_object ().get_member ("user_login").get_string ();
                StreamlinkGtk.Models.Resource resource = new StreamlinkGtk.Models.ResourceStream (
                                                                                                  stream_data.get_object ().get_member ("id").get_string (),
                                                                                                  title,
                                                                                                  thumbnail,
                                                                                                  content_url,
                                                                                                  started_at,
                                                                                                  num_viewers);
                Array<string> css_classes = new Array<string> ();
                css_classes.append_val ("title-3");

                resource.title_css_classes = css_classes;
                resource.subtitle = subtitle;

                contents.resources.append_val (resource);

                // If we got a cursor, we just update the current scrolled window's grid view model.
                if (contents.pagination_cursor.valid == true) {

                    this.scrolled_window_contents.list_store.append (resource);
                }
            }

            contents.pagination_cursor = response.pagination_cursor;

            return true;
        }

        /*
         *
         * VIDEOS
         *
         */
        private async Contents get_contents_videos_async (ContentsSelector contents_selector) {

            Contents contents = new Contents (ContentsId.VIDEOS, "Live streams");

            string uri = ApiEndPoint.VIDEOS;
            if (contents_selector.parameters.has_key ("user_id")) {

                uri += "?user_id=" + contents_selector.parameters.get ("user_id");
            }

            yield this.get_resource_videos_async (uri, contents);

            contents.pagination_cursor.parameters = contents_selector.parameters;
            return contents;
        }

        private async bool get_resource_videos_async (string uri, Contents? contents = null) {

            Response response = yield this.get_response_async (uri, contents);

            if (response.data == null) {
                return false;
            }

            foreach (unowned Json.Node stream_data in response.data.get_elements ()) {

                string id = stream_data.get_object ().get_member ("id").get_string ();

                string title = stream_data.get_object ().get_member ("title").get_string ();

                string thumbnail_url = stream_data.get_object ().get_member ("thumbnail_url").get_string ();
                thumbnail_url = thumbnail_url.replace ("%{width}", this.thumbnail_width.to_string ()).replace ("%{height}", this.thumbnail_height.to_string ()).to_string ();

                string thumbnail_path = this.cache.thumbnails_vod_cache_dir + "/twitch_" + id + ".jpg";

                string created_at_str = stream_data.get_object ().get_member ("created_at").get_string ();
                created_at_str.replace ("Z", "");
                DateTime created_at = new DateTime.from_iso8601 (created_at_str, new TimeZone.local ());

                int num_viewers = (int) stream_data.get_object ().get_member ("view_count").get_int ();

                string duration = stream_data.get_object ().get_member ("duration").get_string ();

                // 1 week cache because why not.
                Thumbnail thumbnail = new Thumbnail (this.thumbnail_width, this.thumbnail_height, thumbnail_url, thumbnail_path, 604800);

                string content_url = stream_data.get_object ().get_member ("url").get_string ();
                StreamlinkGtk.Models.Resource resource = new StreamlinkGtk.Models.ResourceVod (
                                                                                               title,
                                                                                               thumbnail,
                                                                                               content_url,
                                                                                               created_at,
                                                                                               duration,
                                                                                               num_viewers
                );

                contents.resources.append_val (resource);

                // If we got a cursor, we just update the current scrolled window's grid view model.
                if (contents.pagination_cursor.valid == true) {

                    this.scrolled_window_contents.list_store.append (resource);
                }
            }

            contents.pagination_cursor = response.pagination_cursor;

            return true;
        }

        /*
         *
         * Common
         *
         */
        private async Response ? get_response_async (string uri, Contents? contents = null) {

            try {
                string? response_data = yield this.get_response_data_async (uri, contents);

                if (response_data == null) {
                    return null;
                }

                bool succesfully_parsed = this.json_parser.load_from_data (response_data);
                if (succesfully_parsed == true) {

                    Json.Node node_root = this.json_parser.get_root ();
                    if (node_root.get_node_type () != Json.NodeType.OBJECT) {
                        throw new TwitchError.INVALID_FORMAT ("[twitch] Unexpected element type %s", node_root.type_name ());
                    }

                    Json.Node data_node = node_root.get_object ().get_member ("data");
                    if (data_node.get_node_type () != Json.NodeType.ARRAY) {
                        throw new TwitchError.INVALID_FORMAT ("[twitch] Unexpected element type %s", data_node.type_name ());
                    }

                    string cursor = this.get_cursor (node_root);
                    return new Response (data_node.get_array (), new PaginationCursor (cursor.length > 0, cursor, null));
                }
            } catch (Error error) {

                warning ("[twitch] error: %s", error.message);
            }

            return null;
        }

        private async string ? get_response_data_async (string uri, Contents? contents = null) {

            string final_uri = uri;

            if (contents != null) {

                // Get the next contents results.
                if (contents.pagination_cursor.valid == true) {

                    final_uri = final_uri + "?after=" + contents.pagination_cursor.cursor;

                    if (contents.pagination_cursor.parameters != null) {

                        foreach (var parameter in contents.pagination_cursor.parameters) {
                            final_uri = final_uri + "&" + parameter.key + "=" + parameter.value;
                        }
                    }
                }
            }

            debug ("[twtich] final_uri: %s", final_uri);
            string response_data = yield this.api_request.get_request_async (final_uri, false);

            return response_data;
        }

        private string get_cursor (Json.Node node_root) {

            string cursor = "";

            try {

                if (node_root.get_node_type () != Json.NodeType.OBJECT) {

                    throw new TwitchError.INVALID_FORMAT ("[twitch] Unexpected element type %s", node_root.type_name ());
                }

                if (node_root.get_object ().has_member ("pagination")) {

                    Json.Node node_pagination = node_root.get_object ().get_member ("pagination");
                    if (node_pagination.get_node_type () == Json.NodeType.OBJECT) {

                        foreach (unowned string name in node_pagination.get_object ().get_members ()) {

                            if (name == "cursor") {

                                cursor = node_pagination.get_object ().get_string_member ("cursor");
                                debug ("[twitch] got pagination cursor: %s", cursor);
                            }
                        }
                    }
                }
            } catch (Error error) {

                warning ("[twitch] error: %s", error.message);
            }

            return cursor;
        }
    }

    public Type register_plugin (Module module) {
        return typeof (Twitch);
    }
}
