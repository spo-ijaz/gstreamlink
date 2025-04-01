/* provider-plugin-controller.vala
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
// using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models;
using StreamlinkGtk.Models.Providers;
using StreamlinkGtk.Preferences;
using StreamlinkGtk.Services;
// using StreamlinkGtk.Providers;
using StreamlinkGtk.Services;
using StreamlinkGtk.Settings;
// using StreamlinkGtk.StreamingProviders;
// using StreamlinkGtk.Widgets;

namespace StreamlinkGtk.Controllers {

    public class ProviderPluginController : Object {

        public signal void provider_user_updated (ProviderUser provider_user);
        public signal void provider_setup_done (IProviderPlugin provider);

        public Gtk.Application application { get; construct; }
        public GLib.ListStore list_store_plugin_providers { private set; public get; }
        public IProviderPlugin provider { private set; public get; }

        private AppSettings store;
        private Window window;
        private bool overlay_displayed;

        construct {

            this.overlay_displayed = false;
            this.list_store_plugin_providers = new GLib.ListStore (typeof (PluginProvider));
            this.store = AppSettings.get_default ();
        }

        public ProviderPluginController (Gtk.Application application) {
            Object (application: application);
        }

        public void startup_initialization (Window window) {

            this.window = window;

            // Overlay and button load more results.
            this.window.button_load_more_results.clicked.connect (this.button_load_more_results_clicked);

            // Login banner
            this.window.banner_login.button_clicked.connect (this.oauth_login_handler);

            // Provider drop down and startup provider.
            this.window.drop_down_plugin_providers.drop_down.set_model (this.list_store_plugin_providers);

            // Side bar contents selector
            this.window.side_bar_list_box.get_contents.connect (this.get_contents_handler);

            // Initialize all available providers, default one is Twitch.
            this.list_store_plugin_providers.append (new PluginProvider (1, "Twitch", "libstreamlink_gtk_plugin_provider_twitch", "streamlink_gtk_providers_twitch_register_plugin"));
            // this.list_store_plugin_providers.append (new PluginProvider (2, "Twitch 2", "libstreamlink_gtk_plugin_provider_twitch", "streamlink_gtk_providers_twitch_register_plugin"));
            // this.list_store_plugin_providers.append (new PluginProvider (3, "Twitch 3", "libstreamlink_gtk_plugin_provider_twitch", "streamlink_gtk_providers_twitch_register_plugin"));

            // Select the startup provider, it will be Twitch by default.
            uint startup_provider_id = this.store.get_uint ("startup-provider-id") > 0 ? this.store.get_uint ("startup-provider-id") : 1;
            bool startup_provider_found = false;

            // Twitch as default.
            PluginProvider startup_plugin_provider = this.list_store_plugin_providers.get_item (0) as PluginProvider;

            for (uint position = 0; position <= this.list_store_plugin_providers.get_n_items (); position++) {

                startup_plugin_provider = this.list_store_plugin_providers.get_item (position) as PluginProvider;
                if (startup_plugin_provider.id == startup_provider_id) {

                    debug ("Found startup provider: %s", startup_plugin_provider.name);
                    startup_provider_found = true;
                    this.window.drop_down_plugin_providers.drop_down.set_selected (position);
                    break;
                }
            }

            if (startup_provider_found == false) {

                debug ("Using Twtich as default startup provider.");
                this.window.drop_down_plugin_providers.drop_down.set_selected (0);
            }

            // Should not be called at startup, normally.
            this.window.drop_down_plugin_providers.provider_changed.connect (this.provider_changed_handler);

            this.provider_changed_handler (startup_plugin_provider);

            // Start thread handling async providers tasks.
            ProviderAsyncTasks provider_async_tasks = new ProviderAsyncTasks ("Provider Async Tasks Thread", this.list_store_plugin_providers, this.application);
            new Thread<void> ("Provider Async Tasks Thread", provider_async_tasks.run);
        }

        private void activate_plugin_provider (PluginProvider plugin_provider) {

            try {

                debug ("Loading provider plugin: %s", plugin_provider.name);
                ProviderPluginLoader loader = new ProviderPluginLoader ();
                this.provider = loader.load (plugin_provider.library_name, plugin_provider.register_plugin_function_name);
                this.provider.activate ();

                // this.window.drop_down_providers.drop_down.selected = (startup_provider_id - 1);
                this.store.current_provider_id = plugin_provider.id;
                this.store.set_uint ("startup-provider-id", plugin_provider.id);
            } catch (PluginLoaderError e) {

                print ("Error: %s\n", e.message);
            }
        }

        private void provider_changed_handler (PluginProvider plugin_provider_changed) {

            if (this.provider is IProviderPlugin) {

                this.window.banner_login.revealed = false;
                this.provider.provider_plugin_loader.unload ();
            }

            this.activate_plugin_provider (plugin_provider_changed);

            // Signals handlers
            this.provider.got_api_error.connect (display_toast_overlay_api_error);
            this.provider.make_oauth_login.connect (() => {

                this.window.banner_login.revealed = true;
                this.oauth_login_handler ();
            });

            // If we need to login for this provider.
            if (this.provider.user_login_mandatory) {

                this.debug_log ("login mandatory.");
                Models.ProviderUser provider_user = this.store.provider_user;
                this.provider.provider_user = provider_user;
                this.provider.provider_user.provider_id = this.provider.id;

                if (provider_user.is_logged == false) {

                    this.debug_log ("we need to login.");
                    this.window.banner_login.revealed = true;
                } else {


                    this.provider.initialize_api_request ();
                    if (this.provider.provider_user.id == "" || this.provider.provider_user.username == "") {

                        this.debug_log ("we need to fetch provider user info.");
                        this.update_provider_user_info.begin ((obj, res) => {

                            this.update_provider_user_info.end (res);
                            this.provider_ui_reset ();
                        });
                    }

                    this.provider_ui_reset ();
                }
            }
        }

        // Perform an OAuth2 flow to get an access token.
        private void oauth_login_handler () {

            this.window.banner_login.button_label = null;
            this.window.banner_login.title = "Check the opened page in your web-browser.";

            OAuthTokenReceiver oauth_token_receive = new OAuthTokenReceiver ("Http Server Thread", this.provider);
            new Thread<void> ("Http Server Thread", oauth_token_receive.run);

            oauth_token_receive.got_access_token.connect ((access_token) => {

                debug_log ("it seems we got an access token: " + access_token);
                this.window.banner_login.revealed = false;
                this.reset_banner_login_contents ();

                this.provider.provider_user.bearer_token = access_token;
                this.provider.provider_user.is_logged = true;
                this.store.provider_user = this.provider.provider_user;
                this.provider.initialize_api_request ();
                this.update_provider_user_info.begin ((obj, res) => {

                    this.update_provider_user_info.end (res);
                    this.provider_ui_reset ();
                });
            });

            oauth_token_receive.failed_to_get_access_token.connect (() => {

                this.reset_banner_login_contents ();
            });
        }

        private void provider_ui_reset () {

            this.provider_user_updated (this.provider.provider_user);
            this.provider_setup_done (this.provider);

            Adw.Bin bin = this.window.view_stack_page_contents.get_child () as Adw.Bin;
            bin.set_child (this.provider.scrolled_window_contents);

            this.provider.scrolled_window_contents.resource_clicked.connect (this.resource_clicked_handler);
            this.provider.scrolled_window_contents.scrolled_window.edge_reached.connect (this.scrolled_window_edge_reached_handler);
            this.provider.scrolled_window_contents.resource_play_button_clicked.connect (this.resource_play_button_clicked_handler);
        }

        // Get user information from current provider.
        private async void update_provider_user_info () {

            bool provider_user_updated_successfully = yield this.provider.update_provider_user_info_async (this.provider.provider_user);

            if (provider_user_updated_successfully) {

                this.store.provider_user = this.provider.provider_user;
            }
        }

        private void reset_banner_login_contents () {

            this.window.banner_login.button_label = "Login";
            this.window.banner_login.title = "You need to login.";
        }

        /**
         * Initialize main scrolled contents stack page.
         * When userd clicked on a category in side bar
         */
        private void get_contents_handler (ContentsSelector contents_selector) {

            // this.window.sidebar_scrolled_win.sensitive = false;
            this.hide_overlay_more_results ();

            this.provider.get_contents_async.begin (contents_selector, (obj, res) => {

                Contents contents;

                this.provider.get_contents_async.end (res, out contents);
                // this.window.sidebar_scrolled_win.sensitive = true;
                this.window.view_stack_page_contents.title = contents.title;
                this.provider.scrolled_window_contents.provider_got_contents_handler (contents);
            });
        }

        private void scrolled_window_edge_reached_handler (PositionType position_type) {

            if (position_type == PositionType.BOTTOM && this.provider.scrolled_window_contents.contents.pagination_cursor.valid == true) {

                this.display_overlay_more_results ();
            }
        }

        private void button_load_more_results_clicked () {

            // Since the scrolled_window_contents's contents is defined at Provider level, it's up to the Provider
            // to handle the grid view model update.
            this.hide_overlay_more_results ();
            this.provider.get_next_contents_async.begin ((obj, res) => {

                this.provider.get_next_contents_async.end (res);
            });
        }

        private void resource_clicked_handler (Models.Resource resource) {

            if (resource.is_contents_selector) {

                this.get_contents_handler (resource.contents_selector);
            } else {

                // this.window.streaming_controller.play_resource (resource);
            }
        }

        private void resource_play_button_clicked_handler (Models.Resource resource) {

            this.window.streaming_provider_controller.play_resource (resource, this.provider);
        }

        private void debug_log (string message) {

            debug ("[%s] - %s", this.provider.name, message);
        }

        // Overlay
        private void display_overlay_more_results () {

            this.overlay_displayed = true;
            this.window.overlay.add_overlay (this.window.button_load_more_results);
        }

        private void hide_overlay_more_results () {

            if (this.overlay_displayed == true) {

                this.overlay_displayed = false;
                this.window.overlay.remove_overlay (this.window.button_load_more_results);
            }
        }

        private void display_toast_overlay_api_error (Toast toast) {

            this.window.toast_overlay.add_toast (toast);
        }
    }
}
