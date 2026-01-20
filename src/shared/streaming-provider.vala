/* streaming-provider.vala
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

using Gee;
using Posix;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models;
using StreamlinkGtk.Services;


namespace StreamlinkGtk.Interfaces {

    public abstract class StreamingProvider : Object, IStreamingProviderPlugin {

        public IProviderPlugin provider_plugin { get; private set; }
        public IPlayerPlugin player_plugin { get; private set; }
        public GLib.ListStore running_players { get; private set; }

        public override StreamingProviderPluginLoader streaming_provider_plugin_loader { get; set; }

        /**
         * Plugin.
         */
        public abstract string name { get; set; }

        protected string[] spawn_env;
        // protected string[] spawn_args;
        protected ArrayList<string> spawn_args;

        construct {

            this.spawn_env = Environ.get ();
            this.spawn_args = new ArrayList<string> ();
        }

        public async void init (IProviderPlugin provider_plugin, IPlayerPlugin player_plugin, GLib.ListStore running_players) {

            this.provider_plugin = provider_plugin;
            this.player_plugin = player_plugin;
            this.running_players = running_players;
        }

        private static void child_setup_func () {

            Posix.setpgid (0, 0);
        }

        public virtual async void play (Models.Resource resource, Widgets.Providers.Default.Resource resource_widget) {

            try {

                Pid child_pid;

                int standard_input;
                int standard_output;
                int standard_error;

                print ("\nSpawning process with args:\n");
                foreach (var item in spawn_args) {
                    print ("%s ", item);
                }
                print ("\n");

                string[] args = new string[this.spawn_args.size + 1];
                for (int i = 0; i < this.spawn_args.size; i++) {

                    args[i] = this.spawn_args[i];
                }
                args[this.spawn_args.size] = null;

                Process.spawn_async_with_pipes ("/",
                                                args,
                                                this.spawn_env,
                                                SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                                child_setup_func,
                                                out child_pid,
                                                out standard_input,
                                                out standard_output,
                                                out standard_error);



                Models.RunningPlayer current_running_player = null;

                switch (resource.contents_type) {

                case Models.Resource.type.STREAM: {

                    Models.ResourceStream thumbnail_contents_stream = resource as Models.ResourceStream;
                    current_running_player = new Models.RunningPlayer (
                                                                       child_pid,
                                                                       thumbnail_contents_stream.title,
                                                                       thumbnail_contents_stream.thumbnail,
                                                                       thumbnail_contents_stream.content_url,
                                                                       thumbnail_contents_stream.started_at,
                                                                       thumbnail_contents_stream.viewers_count
                    );
                    break;
                }
                case Models.Resource.type.VOD: {

                    Models.ResourceVod thumbnail_contents_vod = resource as Models.ResourceVod;
                    current_running_player = new Models.RunningPlayer (
                                                                       child_pid,
                                                                       thumbnail_contents_vod.title,
                                                                       thumbnail_contents_vod.thumbnail,
                                                                       thumbnail_contents_vod.content_url,
                                                                       new GLib.DateTime.now (),
                                                                       thumbnail_contents_vod.viewers_count
                    );
                    break;
                }
                }

                if (current_running_player == null) {

                    warning ("StreamingProvicer::play Unable to create RunningPlayer instance");
                    return;
                }

                this.running_players.append (current_running_player);
                uint running_players_position = this.running_players.get_n_items () - 1;
                resource.running_player = current_running_player;

                IOChannel output = new IOChannel.unix_new (standard_output);
                output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return this.process_line (channel, condition, "stdout", current_running_player, resource_widget);
                });

                IOChannel error = new IOChannel.unix_new (standard_error);
                error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return this.process_line (channel, condition, "stderr", current_running_player, resource_widget);
                });

                this.player_started (current_running_player);

                this.stream_just_started.connect ((running_player) => {

                    // On all workspace.
                    // @todo only if option enabled in settings.
                    Timeout.add (1000, () => {

                        try {
                            debug ("wmctrl -r " + resource.title + " -b add,sticky");
                            Process.spawn_command_line_async ("wmctrl -r " + resource.title + " -b add,sticky");
                        } catch (SpawnError e) {

                            warning ("Failed to execute wmctrl: %s", e.message);
                        }
                        return false;
                    });
                });

                resource_widget.stop_button_clicked.connect ((resource_from_widget) => {

                    debug (" Stopping process with PID %d", child_pid);
                    current_running_player.stop();
                    this.removedRunningPlayer (resource_from_widget);
                });

                ChildWatch.add (child_pid, (pid, status) => {

                    debug (" Stopping process with PID %d", pid);
                    this.player_stopped (current_running_player, resource_widget);
                    this.removedRunningPlayer (resource);
                });
            } catch (SpawnError e) {

                print ("Error: %s\n", e.message);
            }
        }

        public void registered (Services.StreamingProviderPluginLoader streaming_provider_plugin_loader) {
            this.streaming_provider_plugin_loader = streaming_provider_plugin_loader;
        }

        public void activate () {
            debug ("Streaming provider plugin - %s - activate\n", this.name);
        }

        public void deactivate () {
            debug ("Streaming provider plugin - %s - activate\n", this.name);
        }

        public Services.StreamingProviderPluginLoader provider_plugin_loader { get; set; }

        protected abstract bool process_line (IOChannel channel, IOCondition condition, string stream_name, Models.RunningPlayer running_player, Widgets.Providers.Default.Resource resource_widget);


        private void removedRunningPlayer(Models.Resource resource)
        {
            uint n_items = this.running_players.get_n_items ();
            for (uint i = 0; i < n_items; i++) {

                Models.RunningPlayer? running_player = (Models.RunningPlayer) this.running_players.get_item (i);
                if (running_player.content_url == resource.content_url) {

                    this.running_players.remove (i);
                }
            }

            debug ("RunningPlayer instance not found :  %s", resource.content_url);
        }
    }
}
