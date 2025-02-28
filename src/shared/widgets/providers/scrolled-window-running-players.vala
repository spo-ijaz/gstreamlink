/* viewing-scrolled-running-players.vala
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

namespace StreamlinkGtk.Widgets {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/widgets/scrolled-window-running-players.ui")]

    public class ScrolledWindowRunningPlayers : Bin {

        public signal void running_player_clicked (Models.RunningPlayer running_player);

        [GtkChild]
        public unowned GLib.ListStore list_store;

        construct {
        }

        public ScrolledWindowRunningPlayers () {
            Object ();
        }

        [GtkCallback]
        private void grid_view_signal_setup_handler (ListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            list_item.set_child (new Widgets.RunningPlayer (this));
        }

        [GtkCallback]
        private void grid_view_signal_bind_handler (ListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            if (list_item == null) {

                return;
            }

            Widgets.RunningPlayer running_player = list_item.child as Widgets.RunningPlayer;
            Models.RunningPlayer running_player_model = list_item.item as Models.RunningPlayer;
            running_player.initialize (running_player_model);
        }
    }
}
