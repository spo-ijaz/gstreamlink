/* resource.vala
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

using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Models.Providers;

namespace StreamlinkGtk.Models {

    public abstract class Resource : Object {

        public enum type {
            CONTENTS,
            CHANNEL,
            STREAM,
            VOD
        }

        public bool is_contents_selector { get; set; default = false; }

        public bool initialized { get; set; default = false; }

        public abstract Resource.type contents_type { get; set; }

        public string id { get; construct; }

        public string title { get; construct; }

        public Array<string> title_css_classes { get; set; }

        public string subtitle { get; set; }

        public Thumbnail thumbnail { get; construct; }

        public string content_url { get; construct; }

        public ContentsSelector? contents_selector { get; set; default = null; }

        public RunningPlayer? running_player {  get; set; default = null; }
    }
}
