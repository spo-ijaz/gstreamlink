/* preferences-streaming-providers-settings.vala
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

    public class PreferencesStreamingProvidersSettings : GLib.Settings {

        private static PreferencesStreamingProvidersSettings _preferences_streaming_providers;

        public static unowned PreferencesStreamingProvidersSettings get_default () {

            if (_preferences_streaming_providers == null) {

                _preferences_streaming_providers = new PreferencesStreamingProvidersSettings ();
            }

            return _preferences_streaming_providers;
        }

        public PreferencesStreamingProvidersSettings () {
            Object (schema_id: AppConfig.APP_ID + ".preferences.streaming-providers");
        }
    }
}
