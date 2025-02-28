/* twitch-settings.vala
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

 namespace StreamlinkGtk.Providers.Twitch {

    public class TwitchSettings : GLib.Settings {

        private static TwitchSettings _twitch_settings;

        public static unowned TwitchSettings get_default () {

            if (_twitch_settings == null) {

                _twitch_settings = new TwitchSettings ();
            }

            return _twitch_settings;
        }

        public TwitchSettings () {
            Object (schema_id: AppConfig.APP_ID + ".plugins.providers.twitch");
        }
    }
}
