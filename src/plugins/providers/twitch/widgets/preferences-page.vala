/* preferences-group.vala
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
using StreamlinkGtk.Providers.Twitch;

namespace StreamlinkGtk.Widgets.Providers.Twitch {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/plugins/providers/twitch/preferences-page.ui")]

    public class PreferencesPage : Adw.PreferencesGroup {

        [GtkChild]
        public unowned Adw.EntryRow twitch_session_id;
        [GtkChild]
        public unowned Adw.SwitchRow switch_enable_notifications;
        [GtkChild]
        public unowned Adw.SpinRow spin_auto_refresh_interval;

        private TwitchSettings store;
        private Gtk.Image switch_enable_notifications_icon;

        construct {



            this.store = TwitchSettings.get_default ();
            this.store.changed.connect (on_store_changed);
            this.store.bind ("website-oauth", this.twitch_session_id, "text", SettingsBindFlags.DEFAULT);
            this.store.bind ("enable-notifications", this.switch_enable_notifications, "active", SettingsBindFlags.DEFAULT);
            this.store.bind ("refresh-interval", this.spin_auto_refresh_interval, "value", SettingsBindFlags.DEFAULT);

            this.switch_enable_notifications_icon = new Gtk.Image.from_icon_name (this.store.get_boolean ("enable-notifications") ? "preferences-system-notifications-symbolic" : "notifications-disabled-symbolic");
            this.switch_enable_notifications.add_prefix (this.switch_enable_notifications_icon);
        }

        public PreferencesPage () {
            Object ();
        }

        private void on_store_changed (string key) {


            if (key == "enable-notifications") {

                this.switch_enable_notifications_icon.set_from_icon_name (this.store.get_boolean ("enable-notifications") ? "preferences-system-notifications-symbolic" : "notifications-disabled-symbolic");
                this.spin_auto_refresh_interval.set_sensitive (this.store.get_boolean ("enable-notifications"));
            }
        }
    }
}
