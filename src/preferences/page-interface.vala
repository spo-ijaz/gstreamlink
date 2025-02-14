/* page-interface.vala
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
using StreamlinkGtk.Settings;

namespace StreamlinkGtk.Preferences {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/widgets/preferences/page-interface.ui")]

    public class PageInterface : PreferencesPage {

        [GtkChild]
        public unowned SwitchRow switch_row_minimize_gui;

        construct {

            PreferencesInterfaceSettings preferences_interface_settings = PreferencesInterfaceSettings.get_default ();

            preferences_interface_settings.bind ("minimize-gui", this.switch_row_minimize_gui,
                                                 "active", SettingsBindFlags.DEFAULT);
        }

        public PageInterface () {
            Object ();
        }
    }
}
