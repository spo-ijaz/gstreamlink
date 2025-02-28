/* sidebar-list-box-row.vala
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

using Adw;
using Gtk;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models.Providers;

namespace StreamlinkGtk.Widgets.Providers.Twitch {

    class SideBarListBoxRow : ISideBarListBoxRow, ListBoxRow {

        public bool is_content_selector { get; set; }
        public ContentsSelector contents_selector { get; set; }

        public string title { private get; construct; }

        public SideBarListBoxRow (string title, bool is_content_selector, ContentsSelector contents_selector) {
            Object (
                    title: title,
                    is_content_selector: is_content_selector,
                    contents_selector: contents_selector
            );

            if (this.is_content_selector == false) {

                Adw.PreferencesGroup preference_group = new Adw.PreferencesGroup ();
                preference_group.set_title (this.title);
                this.child = preference_group;
                this.sensitive = false;
            } else {

                Grid grid = new Grid ();
                grid.attach (new Label (this.title), 1, 1, 4, 1);
                this.child = grid;
            }
        }
    }
}
