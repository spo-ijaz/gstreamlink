/* twitch-settings.vala
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

 namespace StreamlinkGtk.Players.Vlc {

    public class VlcSettings : GLib.Settings {

        private static VlcSettings _vlc_settings;

        public static unowned VlcSettings get_default () {

            if (_vlc_settings == null) {

                _vlc_settings = new VlcSettings ();
            }

            return _vlc_settings;
        }

        public VlcSettings () {
            Object (schema_id: AppConfig.APP_ID + ".plugins.players.vlc");
        }
    }
}
