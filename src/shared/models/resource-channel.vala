/* resource-channel.vala
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

    public class ResourceChannel : Resource {

        public override Resource.type contents_type { get; set; default = Resource.type.CHANNEL; }

        construct {
        }

        public ResourceChannel (string title,
            Thumbnail thumbnail,
            string content_url) {
            Object (
                    title: title,
                    thumbnail: thumbnail,
                    content_url: content_url
            );
        }
    }
}
