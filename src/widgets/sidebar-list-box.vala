/* sidebar-list-box.vala
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

using Gtk;
using StreamlinkGtk.Controllers;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models.Providers;


namespace StreamlinkGtk.Widgets {

    public class SideBarListBox : Object {

        public signal void get_contents(ContentsSelector contents_selector);

        public ProviderPluginController provider_controller { private get; construct; }

        public ListBox list_box { get; construct; }

        construct {

            this.list_box = new ListBox();
            this.provider_controller.provider_setup_done.connect(this.update_provider_list_box_rows);

            this.list_box.row_activated.connect(this.row_activated_handler);
        }

        public SideBarListBox(ProviderPluginController provider_controller) {
            Object(provider_controller: provider_controller);
        }

        private void update_provider_list_box_rows(IProviderPlugin provider) {

            this.list_box.remove_all();
            provider.get_side_bar_list_box_rows_async.begin((obj, res) => {

                Array<ISideBarListBoxRow> list_box_rows;
                provider.get_side_bar_list_box_rows_async.end(res, out list_box_rows);

                foreach (ISideBarListBoxRow list_box_row in list_box_rows) {

                    this.list_box.append(list_box_row);
                }
            });
        }

        private void row_activated_handler(ListBoxRow row) {

            ISideBarListBoxRow side_bar_list_box_row = row as ISideBarListBoxRow;

            if (side_bar_list_box_row.is_content_selector == true) {

                this.get_contents(side_bar_list_box_row.contents_selector);
            }
        }
    }
}
