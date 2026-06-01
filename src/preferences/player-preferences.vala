/* page-players.vala
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
using Gtk;
using StreamlinkGtk.Settings;
using StreamlinkGtk.Preferences;
using StreamlinkGtk.Controllers;
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Preferences {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/widgets/preferences/player-preferences.ui")]

    public class PlayerPreferences : PreferencesPage {

        [GtkChild]
        public unowned ComboRow combo_row_player;
        [GtkChild]
        public unowned Bin selected_player_preferences;
        [GtkChild]
        public unowned SignalListItemFactory combo_row_player_factory;
        [GtkChild]
        public unowned Adw.SwitchRow player_on_all_workspaces;
        [GtkChild]
        public unowned Adw.SwitchRow player_on_top;

        public PlayerPluginController player_plugin_controller { get; construct; }

        private PreferencesPlayersSettings store;

        construct {

            this.store = PreferencesPlayersSettings.get_default ();

            // Default  player
            //
            this.combo_row_player.set_model (this.player_plugin_controller.list_store_plugin_players);

            // VLC as default.
            PluginPlayer startup_plugin_player = this.player_plugin_controller.list_store_plugin_players.get_item (0) as PluginPlayer;
            uint startup_player_id = this.store.get_uint ("startup-player-id") > 0 ? this.store.get_uint ("startup-player-id") : 1;

            for (uint position = 0; position <= this.player_plugin_controller.list_store_plugin_players.get_n_items (); position++) {

                startup_plugin_player = this.player_plugin_controller.list_store_plugin_players.get_item (position) as PluginPlayer;
                if (startup_plugin_player.id == startup_player_id) {

                    // startup_provider_found = true;
                    this.combo_row_player.set_selected (position);
                    break;
                }
            }

            // Handle provider selection.
            this.combo_row_player.notify.connect (this.combo_row_player_notify_handler);

            this.selected_player_preferences.set_child (this.player_plugin_controller.player.get_preferences ());

            // Common settings
            this.store.bind ("player-on-all-workspaces", this.player_on_all_workspaces, "active", SettingsBindFlags.DEFAULT);
            this.store.bind ("player-on-top", this.player_on_top, "active", SettingsBindFlags.DEFAULT);
        }

        public PlayerPreferences (PlayerPluginController player_plugin_controller) {
            Object (player_plugin_controller: player_plugin_controller);
        }

        [GtkCallback]
        private void combo_row_player_setup_handler (SignalListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            list_item.set_child (new Label (""));
        }

        [GtkCallback]
        private void combo_row_player_bind_handler (SignalListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            if (list_item.child == null) {

                this.combo_row_player_setup_handler (factory, list_item);
            }

            Label? label = list_item.child as Label;
            PluginPlayer? plugin_provider = list_item.item as PluginPlayer;

            if (label != null && plugin_provider != null) {

                label.set_text (plugin_provider.name);
            }
        }

        private void combo_row_player_notify_handler (ParamSpec paramspec) {

            if (this.combo_row_player.get_model () != null && this.combo_row_player.get_model ().get_n_items () > 0 && paramspec.get_name () == "selected-item") {

                PluginPlayer plugin_player_selected = this.combo_row_player.get_model ().get_item (this.combo_row_player.get_selected ()) as PluginPlayer;
                if (plugin_player_selected != null) {

                    this.store.set_uint ("startup-player-id", plugin_player_selected.id);
                    // @todo should load the plugin when we change
                    this.selected_player_preferences.set_child (this.player_plugin_controller.player.get_preferences ());

                } else {

                    warning ("Unable to get selected provider");
                }
            }
        }
    }
}
