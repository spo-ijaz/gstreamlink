/* preferences-widget.vala
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
using StreamlinkGtk.Players.Vlc;

namespace StreamlinkGtk.Widgets.Players.Vlc {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/plugins/players/vlc/preferences-widget.ui")]

    public class PreferencesGroup : Adw.PreferencesGroup {

        [GtkChild]
        public unowned Adw.SwitchRow switch_enable_minimal_ui;

        private VlcSettings store;

        construct {

            this.store = VlcSettings.get_default ();
            this.store.bind ("minimal-player-layout", this.switch_enable_minimal_ui, "active", SettingsBindFlags.DEFAULT);
        }

        public PreferencesGroup () {
            Object ();
        }
    }
}
