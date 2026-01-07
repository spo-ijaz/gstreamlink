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

    public class TabPageStreamingScrolledWindow : Adw.Bin {

        public IStreamingProviderPlugin streaming_provider  { get; construct; }
        public Models.RunningPlayer running_player  { get; construct; }

        private ScrolledWindow scrolled_window;
        private TextView text_view;
        private TextBuffer text_buffer;

        construct {

            this.text_view = new TextView () {
                editable = false,
                cursor_visible = false,
                wrap_mode = Gtk.WrapMode.WORD_CHAR,
                monospace = true
            };

            this.text_buffer = text_view.get_buffer ();

            this.streaming_provider.std_out.connect ((line, from_running_player) => {

                if (from_running_player.pid == this.running_player.pid) {

                    Gtk.TextIter end_iter;
                    this.text_buffer.get_end_iter (out end_iter);
                    this.text_buffer.insert (ref end_iter, line, -1);
                }
            });

            this.streaming_provider.std_error.connect ((line, from_running_player) => {

                if (from_running_player.pid == this.running_player.pid) {

                    Gtk.TextIter end_iter;
                    this.text_buffer.get_end_iter (out end_iter);
                    this.text_buffer.insert (ref end_iter, line, -1);
                }
            });

            this.scrolled_window = new ScrolledWindow () {
                child = text_view,
            };

            this.child = this.scrolled_window;
        }

        public void startup_initialization () {
        }

        public TabPageStreamingScrolledWindow (IStreamingProviderPlugin streaming_provider,
            Models.RunningPlayer running_player) {

            Object (
                    streaming_provider: streaming_provider,
                    running_player: running_player
            );
        }
    }
}
