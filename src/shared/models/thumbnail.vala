/* thumbnail.vala
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

namespace StreamlinkGtk.Models {

    public class Thumbnail : Object {

        public int width { get; construct; }
        public int height { get; construct; }
        public string url { get; construct; }
        public string path { get; construct; }
        public uint cache_ttl { get; construct; }

        public Thumbnail (int width,
            int height,
            string url,
            string path,
            uint cache_ttl) {
            Object (
                    width: width,
                    height: height,
                    url: url,
                    path: path,
                    cache_ttl: cache_ttl
            );
        }
    }
}
