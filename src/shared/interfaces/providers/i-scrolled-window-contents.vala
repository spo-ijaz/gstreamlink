/* i-scrolled-window-contents.vala
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
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Interfaces.Providers {

    public interface IScrolledWindowContents : Bin {

        public signal void resource_clicked (Models.Resource resource);
        public signal void resource_play_button_clicked (Models.Resource resource);

        public abstract ScrolledWindow scrolled_window { get; }
        public abstract GLib.ListStore list_store { get; }
        public abstract void provider_got_contents_handler (Contents contents);
        //  public abstract void provider_next_contents_handler ();

        // @todo set should be private
        public abstract Models.Contents contents { get; set; }
    }
}
