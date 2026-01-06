/* vlc.vala
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
using GLib;
using StreamlinkGtk.Services;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Players.Vlc;
using StreamlinkGtk.Settings;

namespace StreamlinkGtk.PlayerProviders.Vlc {

    public class Vlc : Object, IPlayerPlugin {

        public string name { get; default = "VLC"; }
        public string exec_name { get; default = "vlc"; }

        public PlayerPluginLoader player_plugin_loader { get; set; }

        public string exec_path { get; construct; default = "vlc"; }

        private PreferencesPlayersSettings player_store;
        private VlcSettings store;

        construct {

            this.store = VlcSettings.get_default ();
            this.player_store = PreferencesPlayersSettings.get_default ();
        }

        public Gtk.Widget get_preferences () {
            return new StreamlinkGtk.Widgets.Players.Vlc.PreferencesGroup ();
        }

        public void activate () {
            debug ("Player plugin - VLC - activate\n");
        }

        public void deactivate () {
            debug ("Player plugin - VLC - deactivate\n");
        }

        public void registered (PlayerPluginLoader player_plugin_loader) {
            this.player_plugin_loader = player_plugin_loader;
        }

        public string get_extra_args_for_streaming_provider (IStreamingProviderPlugin streaming_provider) {

            // streamlink --player vlc --player-args="--video-on-top --qt-minimal-view" https://www.twitch.tv/akwartz best

            // VLC settings
            string extra_args = "";

            Variant variant = this.store.get_value ("minimal-player-layout");
            if (variant.get_boolean ()) {
                extra_args += "--qt-minimal-view";
            }


            // Common player settings
            variant = this.player_store.get_value ("player-on-top");
            if (variant.get_boolean ()) {
                if (extra_args.length > 1) {
                    extra_args += " ";
                }
                extra_args += "--video-on-top";
            }

            return extra_args;
        }
    }

    public Type register_plugin (Module module) {
        return typeof (Vlc);
    }
}
