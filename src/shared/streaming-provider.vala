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
        // public abstract IPlayerProvider player { get; set; }
        // public override Models.RunningPlayer running_player { get; set; }
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

        public async void init (IProviderPlugin provider_plugin, IPlayerPlugin player_plugin) {
            this.provider_plugin = provider_plugin;
            this.player_plugin = player_plugin;
        }

        private void child_setup_func () {

            Posix.setpgid (0, 0);
        }

        public virtual async void play (Models.Resource resource, Widgets.Providers.Default.Resource resource_widget) {

            try {



                Pid child_pid;

                int standard_input;
                int standard_output;
                int standard_error;

                // foreach (var item in spawn_args) {
                // print ("\n> %s\n", item);
                // }
                print ("\nSpawning process with args:\n");
                foreach (var item in spawn_args) {
                    print ("%s ", item);
                }
                print ("\n");

                Process.spawn_async_with_pipes ("/",
                                                this.spawn_args.to_array (),
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

                IOChannel output = new IOChannel.unix_new (standard_output);
                output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return this.process_line (channel, condition, "stdout", current_running_player, resource_widget);
                });

                IOChannel error = new IOChannel.unix_new (standard_error);
                error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return this.process_line (channel, condition, "stderr", current_running_player, resource_widget);
                });


                this.player_started (current_running_player);


                resource_widget.stop_button_clicked.connect ((resource_to_play) => {

                    debug (" Stopping process with PID %d", child_pid);
                    Posix.kill (-(Posix.pid_t) child_pid, Posix.Signal.KILL);
                    Process.close_pid (child_pid);
                });

                ChildWatch.add (child_pid, (pid, status) => {

                    this.player_stopped (current_running_player, resource_widget);
                    Process.close_pid (pid);
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

        // protected abstract bool process_line (GLib.IOChannel channel, GLib.IOCondition condition, string stream_name, Models.RunningPlayer running_player);

        protected virtual bool process_line (IOChannel channel, IOCondition condition, string stream_name, Models.RunningPlayer running_player, Widgets.Providers.Default.Resource resource_widget) {
            if (condition == IOCondition.HUP) {

                this.std_out ("The fd has been closed.", running_player);
                this.player_stopped (running_player, resource_widget);
                return false;
            }

            try {

                string line;
                channel.read_line (out line, null, null);
                debug (running_player.title + " | " + line);
                this.std_out (line, running_player);
            } catch (IOChannelError e) {

                this.std_error ("IOChannelError: " + e.message, running_player);
                return false;
            } catch (ConvertError e) {

                this.std_error ("ConvertError: " + e.message, running_player);
                return false;
            }

            return true;
        }
    }
}
