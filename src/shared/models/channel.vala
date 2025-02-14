/* channel.vala
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

namespace StreamlinkGtk.Models {

    class Channel : Object {

        public string name { get; construct; }
        public string thumbnail_url { get; construct; }
        public string thumbnail_path { get; construct; }

        public Channel (string name, string thumbnail_url) {

            Object (
                    name: name,
                    thumbnail_url: thumbnail_url.replace ("{width}", "440").replace ("{height}", "248").to_string (),
                    thumbnail_path: Environment.get_user_cache_dir () + AppConfig.APP_ID + "/twitch/channels"
            );
        }
    }
}
