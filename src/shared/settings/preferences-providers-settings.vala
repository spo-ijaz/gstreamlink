/* preferences-providers-settings.vala
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

namespace StreamlinkGtk.Settings {

    public class PreferencesProvidersSettings : GLib.Settings {

        private static PreferencesProvidersSettings _preferences_providers_settings;

        public static unowned PreferencesProvidersSettings get_default () {

            if (_preferences_providers_settings == null) {

                _preferences_providers_settings = new PreferencesProvidersSettings ();
            }

            return _preferences_providers_settings;
        }

        public PreferencesProvidersSettings () {
            Object (schema_id: AppConfig.APP_ID + ".preferences.providers");
        }
    }
}
