/* provider-user.vala
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

    public class ProviderUser : Object {

        public uint provider_id { get; set; }
        public string id { get; set; }
        public string username { get; set; }
        public string bearer_token { get; set; }
        public bool is_logged { get; set; }

        public ProviderUser (uint provider_id, string id, string username, string bearer_token, bool is_logged) {
            Object (
                    provider_id: provider_id,
                    id: id,
                    username: username,
                    bearer_token: bearer_token,
                    is_logged: is_logged
            );
        }
    }
}
