/* page-interface.vala
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
using StreamlinkGtk.Settings;

namespace StreamlinkGtk.Preferences {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/widgets/preferences/page-general.ui")]

    public class PageGeneral : PreferencesPage {

        [GtkChild]
        public unowned SwitchRow switch_row_minimize_gui;
        [GtkChild]
        public unowned Adw.SwitchRow switch_row_enable_notification;

        private PreferencesGeneralSettings store;
        private Gtk.Image switch_row_enable_notification_icon;


        construct {

            this.store = PreferencesGeneralSettings.get_default ();
            this.store.changed.connect (on_store_changed);
            store.bind ("minimize-gui", this.switch_row_minimize_gui, "active", SettingsBindFlags.DEFAULT);
            store.bind ("enable-notifications", this.switch_row_enable_notification, "active", SettingsBindFlags.DEFAULT);

            this.switch_row_enable_notification_icon = new Gtk.Image.from_icon_name (this.store.get_boolean ("enable-notifications") ? "preferences-system-notifications-symbolic" : "notifications-disabled-symbolic");
            this.switch_row_enable_notification.add_prefix (this.switch_row_enable_notification_icon);
   
        }

        public PageGeneral () {
            Object ();
        }

        private void on_store_changed (string key) {


            if (key == "enable-notifications") {

                this.switch_row_enable_notification_icon.set_from_icon_name (this.store.get_boolean ("enable-notifications") ? "preferences-system-notifications-symbolic" : "notifications-disabled-symbolic");
            }
        }
    }
}
