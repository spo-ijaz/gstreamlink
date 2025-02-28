/* running-player.vala
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
using StreamlinkGtk.Services;

namespace StreamlinkGtk.Widgets {

    [GtkTemplate(ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/widgets/running-player.ui")]

    public class RunningPlayer : Bin {

        [GtkChild]
        public unowned Label label_title;
        [GtkChild]
        public unowned Picture picture;
        [GtkChild]
        public unowned Button button_stop;

        public ScrolledWindowRunningPlayers scrolled_window_running_player { get; construct; }

        private Models.RunningPlayer running_player;
        private Cache cache;

        construct {

            this.cache = Cache.get_default();
            this.button_stop.clicked.connect(this.button_stop_clicked_handler);
        }

        public class RunningPlayer(ScrolledWindowRunningPlayers scrolled_window_running_player) {
            Object(scrolled_window_running_player: scrolled_window_running_player);
        }

        public void initialize(Models.RunningPlayer running_player) {

            this.running_player = running_player;
            this.label_title.label = running_player.title;

            this.cache.get_file_from_uri_async.begin(running_player.thumbnail.url, running_player.thumbnail.path, running_player.thumbnail.cache_ttl, (obj, res) => {

                bool exists;
                this.cache.get_file_from_uri_async.end(res, out exists);

                if (exists == true) {

                    this.picture.width_request = running_player.thumbnail.width;
                    this.picture.height_request = running_player.thumbnail.height;
                    this.picture.set_filename(running_player.thumbnail.path);
                }
            });
        }

        private void button_stop_clicked_handler(Button buttun_stop) {

            this.scrolled_window_running_player.running_player_clicked(this.running_player);
        }
    }
}
