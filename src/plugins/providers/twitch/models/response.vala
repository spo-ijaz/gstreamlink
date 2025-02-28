/* response.vala
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

using StreamlinkGtk.Models.Providers;

namespace StreamlinkGtk.Providers.Twitch.Models {

    public class Response : Object {

        public Json.Array? data { get; construct; }
        public PaginationCursor pagination_cursor { get; construct; }

        public Response (Json.Array? data,
            PaginationCursor pagination_cursor) {

            Object (
                    data : data,
                    pagination_cursor : pagination_cursor
            );
        }
    }
}
