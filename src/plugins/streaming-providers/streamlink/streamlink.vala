/* streamlink.vala
 *
 * Copyright 2024 PORQUET Sébastien
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

        //  public override IPlayerProvider player { get; set; }

        public override string name { get; set; default = "Streamlink"; }

        public string exec_path { get; set; }

        construct {

            this.exec_path = "streamlink";
            //  this.player = new Vlc ();
        }

        public override async void play (Models.Resource thumbnail_contents, IProviderPlugin provider_plugin) {

            this.spawn_args = { "streamlink", provider_plugin.get_extra_args_for_streaming_provider (this), thumbnail_contents.content_url, "best"};
            
            //  this.spawn_args = { "streamlink", thumbnail_contents.content_url, "best"};
            yield base.play(thumbnail_contents, provider_plugin);
        }
    }

    public Type register_plugin (Module module) {
        return typeof (Streamlink);
    }
}
