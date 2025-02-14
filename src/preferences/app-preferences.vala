/* dialog.vala
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

using Adw;
using StreamlinkGtk.Controllers;

namespace StreamlinkGtk.Preferences {

    public class AppPreferences : PreferencesDialog {

        public ProviderPluginController provider_plugin_controller { get; construct; }

        construct {

            //  this.add (new PageInterface ());
            this.add (new PageStreamingProviders (this.provider_plugin_controller));
            //  this.add (new PagePlayers ());
        }

        public AppPreferences (ProviderPluginController provider_plugin_controller) {

            Object (provider_plugin_controller: provider_plugin_controller);
        }
    }
}
