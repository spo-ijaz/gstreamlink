/* tab-page-streaming.vala
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

using Adw;
using Gtk;
using StreamlinkGtk.Controllers;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models.Providers;


namespace StreamlinkGtk.Widgets {

    public class TabPageStreaming : Object {

        public TabPage tab_page { get; construct; }

        private Window window;
        private Models.RunningPlayer running_player;

        construct {
        }

        public void startup_initialization (Window window) {
            this.window = window;
        }

        public TabPageStreaming () {

            Object ();
        }

        public void add_tab (Models.Resource resource, IProviderPlugin provider_plugin, IStreamingProviderPlugin streaming_provider) {

            // Create ScrolledWindow to contain the TextView
            // TextView text_view = new TextView () {
            // editable = false,
            // cursor_visible = false,
            // wrap_mode = Gtk.WrapMode.WORD_CHAR,
            // monospace = true
            // };

            // TextBuffer text_buffer = text_view.get_buffer ();

            // streaming_provider.std_out.connect ((line, from_running_player) => {

            // if (running_player == null || from_running_player.pid ==  this.running_player.pid) {

            // this.running_player = from_running_player;
            // Gtk.TextIter end_iter;
            // text_buffer.get_end_iter (out end_iter);
            // text_buffer.insert (ref end_iter, line, -1);
            // }
            // });

            // streaming_provider.std_error.connect ((line, from_running_player) => {

            // if (running_player == null || from_running_player.pid ==  this.running_player.pid) {

            // this.running_player = from_running_player;
            // Gtk.TextIter end_iter;
            // text_buffer.get_end_iter (out end_iter);
            // text_buffer.insert (ref end_iter, line, -1);
            // }
            // });

            // ScrolledWindow scrolled_window = new ScrolledWindow () {
            // child = text_view,
            // };

            //  unowned Adw.TabPage tab_page = this.window.log_tab_view.append (
            //                                                                  new TabPageStreamingScrolledWindow (streaming_provider)
            //  );
            //  tab_page.title = resource.title;
            //  tab_page.live_thumbnail = false;
        }
    }
}
