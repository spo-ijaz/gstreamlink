/* vlc.vala
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

using StreamlinkGtk.Interfaces;

namespace StreamlinkGtk.PlayerProviders {

    public class Vlc : Object, IExecOptions {

        public string exec_path { get; construct; default = "vlc"; }

        public Gtk.Widget get_preferences () {
            return new Adw.Bin ();
        }

        public string exec_path2 { get; construct; default = "vlc"; }

        // public Gtk.Widget get_preferences () {
        // assert_not_reached ();
        // }
    }
}
