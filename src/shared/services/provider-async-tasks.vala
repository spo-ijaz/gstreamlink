/* provider-async-tasks.vala
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
using GLib;
using StreamlinkGtk.Settings;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Services {

    public class ProviderAsyncTasks : Object {

        public string name { get; construct; }
        public ListStore list_store_plugin_providers { get; construct; }
        public Gtk.Application application { get; construct; }

        private MainLoop loop;
        private AppSettings store_app;
        private PreferencesGeneralSettings store_preferences_general;

        construct {

            this.store_app = AppSettings.get_default();
            this.store_preferences_general = PreferencesGeneralSettings.get_default();
        }

        public ProviderAsyncTasks(string name, ListStore list_store_plugin_providers, Gtk.Application application) {
            Object(
                   name: name,
                   list_store_plugin_providers: list_store_plugin_providers,
                   application: application
            );
        }

        public void run() {

            this.loop = new MainLoop();
            Timeout.add_seconds(60, start_async_tasks);
            loop.run();
        }

        public void quit() {

            this.loop.quit();
        }

        private bool start_async_tasks() {

            for (uint i = 0; i < this.list_store_plugin_providers.get_n_items(); i++) {

                PluginProvider plugin_provider = this.list_store_plugin_providers.get_item(i) as PluginProvider;

                try {

                    debug("Loading provider plugin: %s", plugin_provider.name);
                    ProviderPluginLoader loader = new ProviderPluginLoader();
                    IProviderPlugin provider = loader.load(plugin_provider.library_name, plugin_provider.register_plugin_function_name);
                    provider.activate();
                    provider.provider_user = this.store_app.provider_user;
                    provider.initialize_api_request();

                    if (this.store_preferences_general.get_boolean("enable-notifications")) {

                        provider.notification.connect(this.on_notification);
                    }

                    debug("Calling perform_async_tasks() for %s", plugin_provider.name);
                    provider.perform_async_tasks.begin((obj, res) => {
                        provider.provider_plugin_loader.unload();
                    });
                
                } catch (PluginLoaderError e) {

                    print("Error: %s\n", e.message);
                }
            }

            return true;
        }

        private void on_notification(string notification_id, Notification notification) {

            this.application.send_notification(this.application.get_application_id() + notification_id, notification);
        }
    }
}
