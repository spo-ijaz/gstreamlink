/* streamlink.vala
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

using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;

namespace StreamlinkGtk.StreamingProviders {

    public class Streamlink : StreamingProvider  {

        // public override IPlayerProvider player { get; set; }
        public override string name { get; set; default = "Streamlink"; }

        public string exec_path { get; set; }

        construct {

            // this.exec_path = "streamlink";
            // this.player = new Vlc ();
        }
        public override async void play (Models.Resource thumbnail_contents, Widgets.Providers.Default.Resource resource_widget) {

            // streamlink --player vlc --player-args="--qt-minimal-view --video-on-top" --twitch-api-header=Authorization=OAuth yc2u3ow5qe912yo9vbz1cnsieuizcx --hls-start-offset=00:16:45 https://www.twitch.tv/videos/2515177815 best
            // streamlink --player vlc --player-args=--qt-minimal-view --video-on-top --twitch-api-header=Authorization=OAuth yc2u3ow5qe912yo9vbz1cnsieuizcx https://www.twitch.tv/akwartz best
            // raw - working
            // streamlink --player vlc --player-args="--qt-minimal-view --video-on-top" --twitch-api-header="Authorization=OAuth yc2u3ow5qe912yo9vbz1cnsieuizcx" "https://www.twitch.tv/akwartz" best

            this.spawn_args.clear ();
            this.spawn_args.add ("streamlink");

            // Player args.
            this.spawn_args.add ("--player");
            this.spawn_args.add (this.player_plugin.exec_name);

            string player_plugin_extra_args = this.player_plugin.get_extra_args_for_streaming_provider (this);
            if (player_plugin_extra_args != "") {

                this.spawn_args.add ("--player-args=" + player_plugin_extra_args);
            }

            // Video provider args
            string provider_plugin_extra_args = this.provider_plugin.get_extra_args_for_streaming_provider (this);
            if (provider_plugin_extra_args != "") {

                this.spawn_args.add (provider_plugin_extra_args);
            }

            this.get_extra_arg_vod_start_at (thumbnail_contents);

            this.spawn_args.add (thumbnail_contents.content_url);
            this.spawn_args.add ("best");


            // this.spawn_args = {
            // "streamlink",
            // provider_plugin.get_extra_args_for_streaming_provider (this),
            // this.get_extra_arg_vod_start_at (thumbnail_contents),
            // thumbnail_contents.content_url,
            // "best"
            // };

            // this.spawn_args = { "streamlink", thumbnail_contents.content_url, "best"};
            yield base.play (thumbnail_contents, resource_widget);
        }

        private void get_extra_arg_vod_start_at (Models.Resource resource) {

            if (resource is Models.ResourceVod) {

                if ((resource as Models.ResourceVod).start_at_seconds > 0) {

                    this.spawn_args.add ("--hls-start-offset=" + this.format_to_hh_mm_dd ((resource as Models.ResourceVod).start_at_seconds));
                }
            }
        }

        // convert seconds to DD:HH:MM:SS string
        private string format_to_hh_mm_dd (int total_seconds) {

            int hours = total_seconds / 3600;
            int minutes = (total_seconds % 3600) / 60;
            int seconds = total_seconds % 60;
            return "%02d:%02d:%02d".printf (hours, minutes, seconds);
        }

        protected new bool process_line (IOChannel channel, IOCondition condition, string stream_name, Models.RunningPlayer running_player, Widgets.Providers.Default.Resource resource_widget) {

            if (base.process_line (channel, condition, stream_name, running_player, resource_widget) == false) {

                try {

                    string line;
                    channel.read_line (out line, null, null);

                    if (line != null && (line.contains ("Resuming stream output") || line.contains ("Will skip ad segments"))) {

                        this.stream_just_started (running_player);
                    }
                } catch (IOChannelError e) {

                    this.std_error ("IOChannelError: " + e.message, running_player);
                    return false;
                } catch (ConvertError e) {

                    this.std_error ("ConvertError: " + e.message, running_player);
                    return false;
                }
            }

            return true;
        }
    }

    public Type register_plugin (Module module) {
        return typeof (Streamlink);
    }
}
