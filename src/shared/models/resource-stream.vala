/* resource-stream.vala
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

using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Services;

namespace StreamlinkGtk.Models {

    public class ResourceStream : Resource {

        public override Resource.type contents_type { get; set; default = Resource.type.STREAM; }

        public DateTime started_at { get; set; }

        public int viewers_count { get; set; }

        public string elapsed_time { get; set; }

        construct {

        }

        public ResourceStream (string title,
            Thumbnail thumbnail,
            string content_url,
            DateTime started_at,
            int viewers_count) {
            Object (
                    title: title,
                    thumbnail: thumbnail,
                    content_url: content_url,
                    started_at: started_at,
                    viewers_count: viewers_count
            );

            this.elapsed_time = Tools.elapsed_time (this.started_at, new DateTime.now ());
        }
    }
}
