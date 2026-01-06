/* preferences-interface-settings.vala
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

namespace StreamlinkGtk.Settings {

    public class PreferencesGeneralSettings : GLib.Settings {

        private static PreferencesGeneralSettings _preferences_interface_settings;

        public static unowned PreferencesGeneralSettings get_default () {

            if (_preferences_interface_settings == null) {

                _preferences_interface_settings = new PreferencesGeneralSettings ();
            }

            return _preferences_interface_settings;
        }

        public PreferencesGeneralSettings () {
            Object (schema_id: AppConfig.APP_ID + ".preferences.general");
        }
    }
}
