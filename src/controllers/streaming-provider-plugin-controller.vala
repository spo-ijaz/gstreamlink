/* streaming-controller.vala
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
using StreamlinkGtk;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models;
using StreamlinkGtk.Services;
using StreamlinkGtk.Controllers;
using StreamlinkGtk.Widgets;

namespace StreamlinkGtk.StreamingProviders {

    public class StreamingProviderPluginController : Object {

        // public ViewStackPage view_stack_page_running_players { get; construct; }
        public ProviderPluginController provider_plugin_controller { get; construct; }
        public PlayerPluginController player_plugin_controller { get; construct; }

        // private ScrolledWindowRunningPlayers scrolled_window_viewing;
        private IStreamingProviderPlugin streaming_provider;
        private GLib.ListStore list_store_plugin_streaming_providers;
        private Window window;
        private TabPageStreaming tab_page_streaming;

        construct {

            // Initialize all available streaming providers, default one is Streamlink.
            this.list_store_plugin_streaming_providers = new GLib.ListStore (typeof (PluginStreamingProvider));
            this.list_store_plugin_streaming_providers.append (new PluginStreamingProvider (1, "Streamlink", "libstreamlink_gtk_plugin_streaming_provider_streamlink", "streamlink_gtk_streaming_providers_register_plugin"));

            // Activate the first and only one (for now)
            this.activate_plugin_streaming_provider (this.list_store_plugin_streaming_providers.get_item (0) as PluginStreamingProvider);

            // this.streaming_provider = new StreamingProviders.Streamlink();
            // this.scrolled_window_viewing = new ScrolledWindowRunningPlayers();

            // this.scrolled_window_viewing.running_player_clicked.connect(this.running_player_clicked_handler);

            // Adw.Bin bin = this.view_stack_page_running_players.get_child() as Adw.Bin;
            // bin.set_child(this.scrolled_window_viewing);

            this.streaming_provider.player_started.connect (this.player_started_handler);
            this.streaming_provider.player_stopped.connect (this.player_stopped_handler);
        }

        public StreamingProviderPluginController (PlayerPluginController player_plugin_controller,
            ProviderPluginController provider_plugin_controller) {
            Object (
                    player_plugin_controller: player_plugin_controller,
                    provider_plugin_controller: provider_plugin_controller
            );
        }

        public void play_resource (Models.Resource resource, IProviderPlugin provider_plugin) {

            debug ("---------> %s ", resource.title);

            this.streaming_provider.play.begin (resource, (obj, res) => {

                this.streaming_provider.play.end (res);
            });
        }

        public void startup_initialization (Window window) {

            this.window = window;
            this.tab_page_streaming = new TabPageStreaming ();
            this.tab_page_streaming.startup_initialization (window);
        }

        private void player_started_handler (Models.RunningPlayer running_player) {


            unowned Adw.TabPage tab_page = this.window.log_tab_view.append (
                                                                            new TabPageStreamingScrolledWindow (this.streaming_provider, running_player)
            );
            tab_page.title = running_player.title;
            tab_page.live_thumbnail = false;
        }

        private void player_stopped_handler (Models.RunningPlayer running_player) {

            for (int i = 0; i < this.window.log_tab_view.get_n_pages (); i++) {

                unowned Adw.TabPage tab_page = this.window.log_tab_view.get_nth_page (i);

                TabPageStreamingScrolledWindow tab_page_scrolled_window = tab_page.get_child () as TabPageStreamingScrolledWindow;

                if (tab_page_scrolled_window.running_player.pid == running_player.pid) {

                    this.window.log_tab_view.close_page (tab_page);
                    break;
                }
            }
        }

        private void activate_plugin_streaming_provider (PluginStreamingProvider plugin_streaming_provider) {

            try {

                debug ("Loading streaming provider plugin: %s", plugin_streaming_provider.name);
                StreamingProviderPluginLoader loader = new StreamingProviderPluginLoader ();
                this.streaming_provider = loader.load (plugin_streaming_provider.library_name, plugin_streaming_provider.register_plugin_function_name);
                this.streaming_provider.activate ();
                this.streaming_provider.init.begin (this.provider_plugin_controller.provider, this.player_plugin_controller.player);
            } catch (PluginLoaderError e) {

                print ("Error: %s\n", e.message);
            }
        }
    }
}
