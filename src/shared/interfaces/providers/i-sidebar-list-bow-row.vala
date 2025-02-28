/* i-sidebar-list-box-row.vala
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

using Gtk;
using StreamlinkGtk.Models.Providers;

namespace StreamlinkGtk.Interfaces.Providers {

    public interface ISideBarListBoxRow : ListBoxRow {

        public abstract bool is_content_selector { get; set; }
        public abstract ContentsSelector contents_selector { get; set; }
    }
}
