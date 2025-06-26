/* streaming-provider.vala
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

using Gee;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models;
using StreamlinkGtk.Services;


namespace StreamlinkGtk.Interfaces {

    public abstract class StreamingProvider : Object, IExecOptions, IStreamingProviderPlugin   {

        //  public abstract IPlayerProvider player { get; set; }
        public override Models.RunningPlayer running_player { get; set; }
        public override StreamingProviderPluginLoader streaming_provider_plugin_loader { get; set; }

        /**
         * Plugin.
         */
        public abstract string name { get; set; }


        protected string[] spawn_env;
        //protected string[] spawn_args;
        protected  ArrayList<string> spawn_args;

        construct {

            this.spawn_env = Environ.get ();
            this.spawn_args = new ArrayList<string> ();
        }

        public virtual async void play (Models.Resource thumbnail_contents, IProviderPlugin provider_plugin) {

            try {

                Models.ResourceStream thumbnail_contents_stream = thumbnail_contents as Models.ResourceStream;

                Pid child_pid;

                int standard_input;
                int standard_output;
                int standard_error;

                foreach (var item in spawn_args) {
                    print ("\n> %s\n", item);
                }

                Process.spawn_async_with_pipes ("/",
                                                this.spawn_args.to_array(),
                                                this.spawn_env,
                                                SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                                null,
                                                out child_pid,
                                                out standard_input,
                                                out standard_output,
                                                out standard_error);

                IOChannel output = new IOChannel.unix_new (standard_output);
                output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stdout");
                });

                IOChannel error = new IOChannel.unix_new (standard_error);
                error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                    return process_line (channel, condition, "stderr");
                });

                Models.RunningPlayer thumbnail_viewing = new Models.RunningPlayer (
                                                                                   child_pid,
                                                                                   thumbnail_contents_stream.title,
                                                                                   thumbnail_contents_stream.thumbnail,
                                                                                   thumbnail_contents_stream.content_url,
                                                                                   thumbnail_contents_stream.started_at,
                                                                                   thumbnail_contents_stream.viewers_count
                );

                this.player_started (thumbnail_viewing);

                ChildWatch.add (child_pid, (pid, status) => {

                    this.player_stopped (thumbnail_viewing);
                    Process.close_pid (pid);
                });
            } catch (SpawnError e) {

                print ("Error: %s\n", e.message);
            }
        }

        private static bool process_line (IOChannel channel, IOCondition condition, string stream_name) {

            if (condition == IOCondition.HUP) {
                print ("%s: The fd has been closed.\n", stream_name);
                return false;
            }

            try {
                string line;
                channel.read_line (out line, null, null);
                print ("|||-> %s: %s", stream_name, line);
            } catch (IOChannelError e) {
                print ("%s: IOChannelError: %s\n", stream_name, e.message);
                return false;
            } catch (ConvertError e) {
                print ("%s: ConvertError: %s\n", stream_name, e.message);
                return false;
            }

            return true;
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
    }
}
