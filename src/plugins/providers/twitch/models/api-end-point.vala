/* api-end-point.vala
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

namespace StreamlinkGtk.Providers.Twitch.Models {

    class ApiEndPoint {

        public const string CHANNELS = "/channels";
        public const string CHANNELS_FOLLOWED = "/channels/followed";
        public const string STREAMS = "/streams";
        public const string STREAM_FOLLOWED = "/streams/followed";
        public const string USERS = "/users";
        public const string VIDEOS = "/videos";
        public const string SEARCH_CHANNELS = "/search/channels";
        public const string GAMES_TOP = "/games/top";
    }
}
