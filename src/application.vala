/* application.vala
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

using StreamlinkGtk.Controllers;
using StreamlinkGtk.Preferences;

namespace StreamlinkGtk {

    public class Application : Adw.Application {

        public ProviderPluginController provider_plugin_controller { get; construct; }
        public Application () {

            Object (application_id: AppConfig.APP_ID, flags: ApplicationFlags.DEFAULT_FLAGS);
        }

        construct {

            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "provider-preferences", this.on_provider_preferences_action },
                { "quit", this.quit }
            };

            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.preferences", { "<primary>p" });
            this.set_accels_for_action ("app.quit", { "<primary>q" });

            this.provider_plugin_controller = new ProviderPluginController (this);
        }

        public override void activate () {

            base.activate ();
            var win = this.active_window;

            if (win == null) {

                win = new StreamlinkGtk.Window (this, this.provider_plugin_controller);
            }

            win.present ();
        }

        private void on_about_action () {

            string[] developers = { "PORQUET Sébastien <sebastien.porquet@ijaz.fr>" };

            var about = new Adw.AboutDialog () {
                application_name = "Streamlink GTK",
                application_icon = AppConfig.APP_ID,
                developer_name = "PORQUET Sébastien",
                version = AppConfig.PACKAGE_VERSION,
                developers = developers,
                copyright = "© 2025 PORQUET Sébastien",
                license_type = Gtk.License.GPL_3_0
            };

            about.present (this.active_window);
        }

        private void on_preferences_action () {

            PreferencesWindow preferences_window = new PreferencesWindow (this.provider_plugin_controller);
            preferences_window.present (this.active_window);
        }

        private void on_provider_preferences_action () {

            ProviderPreferences dialog_preferences = new ProviderPreferences (this.provider_plugin_controller);
            dialog_preferences.present (this.active_window);
        }
    }
}
