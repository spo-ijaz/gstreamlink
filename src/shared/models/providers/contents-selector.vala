/* content-selector.vala
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

using Gee;

namespace StreamlinkGtk.Models.Providers {

    public class ContentsSelector : Object {

        // Provider specific, used in the sidebar list box.
        public uint contents_id { get; construct; }
        public HashMap<string, string>? parameters { get; construct; }

        public ContentsSelector (uint contents_id,
            HashMap<string, string>? parameters) {
            Object (
                    contents_id : contents_id,
                    parameters : parameters
            );
        }
    }
}
