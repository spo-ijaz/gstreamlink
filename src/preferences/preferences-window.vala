/* preferences-window.vala
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
using Gtk;
using StreamlinkGtk.Controllers;

namespace StreamlinkGtk.Preferences {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/widgets/preferences/preferences-window.ui")]

    public class PreferencesWindow : Adw.PreferencesDialog {
        
        public ProviderPluginController provider_plugin_controller { get; construct; }
        public PlayerPluginController player_plugin_controller { get; construct; }

        [GtkChild]
        public unowned Adw.NavigationPage navigation_page;

        construct {

            this.add (new PageGeneral ());
            this.add (new PageProviders (this.provider_plugin_controller));
            this.add (new PagePlayers (this.player_plugin_controller));
        }

        public PreferencesWindow (
            ProviderPluginController provider_plugin_controller,
            PlayerPluginController player_plugin_controller

        ) {
            Object (
                provider_plugin_controller: provider_plugin_controller,
                player_plugin_controller: player_plugin_controller
            );
        }
    }
}
