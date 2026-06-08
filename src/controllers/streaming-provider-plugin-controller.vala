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

        public ProviderPluginController provider_plugin_controller { get; construct; }
        public PlayerPluginController player_plugin_controller { get; construct; }
        public GLib.ListStore running_players { get; construct; }

        public IStreamingProviderPlugin streaming_provider { get; private set; }
        private GLib.ListStore list_store_plugin_streaming_providers;
        private Window window;
        private TabPageStreaming tab_page_streaming;

        construct {

            // Initialize all available streaming providers, default one is Streamlink.
            this.list_store_plugin_streaming_providers = new GLib.ListStore (typeof (PluginStreamingProvider));
            this.list_store_plugin_streaming_providers.append (new PluginStreamingProvider (1, "Streamlink", "libstreamlink_gtk_plugin_streaming_provider_streamlink", "streamlink_gtk_streaming_providers_register_plugin"));

            // Activate the first and only one (for now)
            this.activate_plugin_streaming_provider (this.list_store_plugin_streaming_providers.get_item (0) as PluginStreamingProvider);

            this.streaming_provider.player_started.connect (this.player_started_handler);
            this.streaming_provider.player_stopped.connect (this.player_stopped_handler);
            // this.streaming_provider.stream_started.connect(this.stream_started);

            this.player_plugin_controller.player_changed.connect (this.on_player_changed);
        }

        private void on_player_changed () {

            if (this.streaming_provider != null) {

                this.streaming_provider.init.begin (this.provider_plugin_controller.provider, this.player_plugin_controller.player, this.running_players);
            }
        }

        public StreamingProviderPluginController (PlayerPluginController player_plugin_controller,
            ProviderPluginController provider_plugin_controller,
            GLib.ListStore running_players) {
            Object (
                    player_plugin_controller: player_plugin_controller,
                    provider_plugin_controller: provider_plugin_controller,
                    running_players: running_players
            );
        }

        public void play_resource (Models.Resource resource, IProviderPlugin provider_plugin, Widgets.Providers.Default.Resource resource_widget) {

            this.streaming_provider.play.begin (resource, resource_widget, (obj, res) => {

                if (resource_widget == null) {

                    return;
                }

                switch (resource.contents_type) {
                    case Models.Resource.type.STREAM: {

                        (resource_widget as Widgets.Providers.Default.ResourceStream).stream_just_started ();
                        break;
                    }
                    case Models.Resource.type.VOD: {

                        (resource_widget as Widgets.Providers.Default.ResourceVod).stream_just_started ();
                        break;
                    }
                    default: {

                        break;
                    }
                }

                this.streaming_provider.play.end (res);
            });
        }

        public void stop_resource (Models.Resource resource, IProviderPlugin provider_plugin, Widgets.Providers.Default.Resource resource_widget) {
        }

        public void startup_initialization (Window window) {

            this.window = window;
            this.tab_page_streaming = new TabPageStreaming ();
            this.tab_page_streaming.startup_initialization (window);
        }

        private void player_started_handler (Models.RunningPlayer running_player) {

            this.window.toggle_log_contents_button.add_css_class ("highlight-log-button");
            GLib.Timeout.add (2500, () => {
                this.window.toggle_log_contents_button.remove_css_class ("highlight-log-button");
                return GLib.Source.REMOVE;
            });

            unowned Adw.TabPage tab_page = this.window.log_tab_view.append (
                                                                            new TabPageStreamingScrolledWindow (this.streaming_provider, running_player)
            );
            tab_page.title = running_player.title;
            tab_page.live_thumbnail = false;
        }

        private void player_stopped_handler (Models.RunningPlayer running_player, Widgets.Providers.Default.Resource resource_widget) {

            debug ("---------------------------------------- 4");
            switch (resource_widget.resource.contents_type) {
            case Models.Resource.type.STREAM: {

                (resource_widget as Widgets.Providers.Default.ResourceStream).stream_stopped ();
                break;
            }
            case Models.Resource.type.VOD: {

                (resource_widget as Widgets.Providers.Default.ResourceVod).stream_stopped ();
                break;
            }
            default: {

                break;
            }
            }

            for (int i = 0; i < this.window.log_tab_view.get_n_pages (); i++) {

                unowned Adw.TabPage tab_page = this.window.log_tab_view.get_nth_page (i);

                TabPageStreamingScrolledWindow tab_page_scrolled_window = tab_page.get_child () as TabPageStreamingScrolledWindow;

                if (tab_page_scrolled_window.running_player.pid == running_player.pid) {

                    this.window.log_tab_view.close_page (tab_page);
                    break;
                }
            }

            if (this.window.log_tab_view.get_n_pages () == 0) {

                this.window.toggle_log_contents_button.active = false;
            }
        }

        // private void stream_started(Models.RunningPlayer running_player) {
        // debug("StreamingProviderPluginController::stream_started");
        // }

        private void activate_plugin_streaming_provider (PluginStreamingProvider plugin_streaming_provider) {

            try {

                debug ("Loading streaming provider plugin: %s", plugin_streaming_provider.name);
                StreamingProviderPluginLoader loader = new StreamingProviderPluginLoader ();
                this.streaming_provider = loader.load (plugin_streaming_provider.library_name, plugin_streaming_provider.register_plugin_function_name);
                this.streaming_provider.activate ();
                this.streaming_provider.init.begin (this.provider_plugin_controller.provider, this.player_plugin_controller.player, this.running_players);
            } catch (PluginLoaderError e) {

                print ("Error: %s\n", e.message);
            }
        }
    }
}