/* player-plugin-controller.vala
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
using Gtk;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Models;
using StreamlinkGtk.Models.Providers;
using StreamlinkGtk.Preferences;
using StreamlinkGtk.Services;
using StreamlinkGtk.Settings;

namespace StreamlinkGtk.Controllers {

    public class PlayerPluginController : Object {

        public Gtk.Application application { get; construct; }
        public GLib.ListStore list_store_plugin_players { private set; public get; }

        public IPlayerPlugin player { private set; public get; }

        private AppSettings store;

        construct {

            this.list_store_plugin_players = new GLib.ListStore (typeof (PluginPlayer));
            this.store = AppSettings.get_default ();
        }

        public PlayerPluginController (Gtk.Application application) {
            Object (application: application);
        }

        public void startup_initialization (Window window) {

             // Initialize all available providers, default one is Twitch.
            this.list_store_plugin_players.append (new PluginPlayer (1, "VLC", "libstreamlink_gtk_plugin_player_vlc", "streamlink_gtk_player_providers_vlc_register_plugin"));
            
            // VLC as default.
            PluginPlayer startup_plugin_player = this.list_store_plugin_players.get_item (0) as PluginPlayer;

            this.player_changed_handler (startup_plugin_player);
        }

        private void activate_plugin_player (PluginPlayer plugin_player) {

            try {

                debug ("Loading player plugin: %s", plugin_player.name);
                PlayerPluginLoader loader = new PlayerPluginLoader ();
                this.player = loader.load (plugin_player.library_name, plugin_player.register_plugin_function_name);
                this.player.activate ();

                //  this.store.current_player_id = plugin_player.id;
                //  this.store.set_uint ("startup-player-id", plugin_player.id);
            } catch (PluginLoaderError e) {

                print ("Error: %s\n", e.message);
            }
        }

        private void player_changed_handler (PluginPlayer plugin_player_changed) {

            if (this.player is IPlayerPlugin) {

                this.player.player_plugin_loader.unload ();
            }

            this.activate_plugin_player (plugin_player_changed);

            // Signals handlers
            //this.player.got_api_error.connect (this.display_toast_overlay_api_error);
        }
    }
}
