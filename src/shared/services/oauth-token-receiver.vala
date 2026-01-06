/* oauth-token-receiver.vala
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

using GLib;
using StreamlinkGtk.Interfaces.Providers;

namespace StreamlinkGtk.Services {

    public class OAuthTokenReceiver : Object {

        public signal void got_access_token (string access_token);
        public signal void failed_to_get_access_token ();

        public IProviderPlugin provider { get; construct; }
        public string name { get; construct; }


        private string oauth_receive_script;
        private string oauth_token_path = Environment.get_user_cache_dir () + "/oauth_token";
        private Pid oauth_receive_script_child_pid;
        private MainLoop loop;

        construct {

            if (AppConfig.PROFILE == "dev") {

                this.oauth_receive_script = Environment.get_current_dir () + "/data/python/streamlink_gtk_twitch_oauth_receive.py";
            } else {

                this.oauth_receive_script = "/usr/share/org.gnome.gitlab.spoijaz.streamlink-gtk/streamlink_gtk_twitch_oauth_receive.py";
            }
        }

        public OAuthTokenReceiver (string name, IProviderPlugin provider) {
            Object (name: name, provider: provider);
        }

        public void run () {

            this.loop = new MainLoop ();

            this.start_http_server ();
            this.wait_before_opening_authorize_url.begin ();

            loop.run ();
        }

        private async void wait_before_opening_authorize_url () {

            GLib.Timeout.add (1000, () => {

                this.open_authorize_url ();
                return false;
            }, GLib.Priority.DEFAULT);
            yield;
        }

        private void start_http_server () {

            try {

                string[] spawn_args = { "python3", this.oauth_receive_script, this.oauth_token_path };
                string[] spawn_env = Environ.get ();

                Process.spawn_async ("/",
                                     spawn_args,
                                     spawn_env,
                                     SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                     null,
                                     out this.oauth_receive_script_child_pid);

                ChildWatch.add (this.oauth_receive_script_child_pid, (pid, status) => {
                    Process.close_pid (this.oauth_receive_script_child_pid);
                    debug ("Closing HTTP server - %s - %s", this.oauth_receive_script_child_pid.to_string (), status.to_string ("%u"));

                    File tokenfile = File.new_for_path (this.oauth_token_path);
                    if (tokenfile.query_exists ()) {

                        uint8[] contents;
                        string? etag_out;
                        try {
                            if (tokenfile.load_contents (null, out contents, out etag_out)) {

                                debug ("Access token: %s", (string) contents);
                                this.got_access_token ((string) contents);
                            } else {

                                this.failed_to_get_access_token ();
                                warning ("Unable to fetch bearer token :/");
                            }
                        } catch (GLib.Error error) {
                            warning (error.message);
                        }

                        this.loop.quit ();
                    }
                });
            } catch (SpawnError spawn_error) {

                warning (spawn_error.message);
            }
        }

        private void open_authorize_url () {

            try {

                Pid child_pid;
                Process.spawn_async ("/",
                                     { "xdg-open", this.provider.authorize_url },
                                     Environ.get (),
                                     SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                     null,
                                     out child_pid);

                ChildWatch.add (child_pid, (pid, status) => {
                    Process.close_pid (pid);
                });
            } catch (SpawnError spawn_error) {

                warning ("%s", spawn_error.message);
            }
        }
    }
}
