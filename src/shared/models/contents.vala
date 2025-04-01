/* contents.vala
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

using Gee;
using Gtk;
using StreamlinkGtk.Models.Providers;

namespace StreamlinkGtk.Models {

    public class Contents : Object {

        // ID custom to the current provider.
        public uint contents_id { get; construct; }
        public string title { get; construct; }
        public PaginationCursor? pagination_cursor { get; set; }
        public Array<Resource> resources { get; construct; }

        construct {

            this.pagination_cursor = new PaginationCursor (false, "", null);
            this.resources = new Array<Resource> ();
        }

        public Contents (uint contents_id, string title) {
            Object (contents_id : contents_id,
                    title: title);
        }

        public ArrayList<string> get_resource_ids () {

            ArrayList<string> ids = new ArrayList<string> ();

            foreach (Resource resource in this.resources) {

                ids.add (resource.id);
            }

            return ids;
        }
    }
}
