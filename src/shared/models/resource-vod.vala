/* resource-stream.vala
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

using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Services;

namespace StreamlinkGtk.Models {

    public class ResourceVod : Resource {

        public override Resource.type contents_type { get; set; default = Resource.type.VOD; }

        public DateTime published_at { get; set; }

        public string duration { get; set; }

        public int start_at_seconds { get; set; default = 0; }

        public int viewers_count { get; set; }

        construct {
        }

        public ResourceVod (string title,
            Thumbnail thumbnail,
            string content_url,
            DateTime published_at,
            string duration,
            int viewers_count) {
            Object (
                    title: title,
                    thumbnail: thumbnail,
                    content_url: content_url,
                    published_at: published_at,
                    duration: duration,
                    viewers_count: viewers_count
            );
        }
    }
}
