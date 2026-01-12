/* i-streaming-provider.vala
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
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models;
using StreamlinkGtk.Services;


namespace StreamlinkGtk.Interfaces.StreamingProviders {

    public interface IStreamingProviderPlugin : Object {

        public abstract IProviderPlugin provider_plugin { get; set; }
        public abstract IPlayerPlugin player_plugin { get; set; }

        public signal void player_started (RunningPlayer running_player);
        public signal void player_stopped (RunningPlayer running_player, Widgets.Providers.Default.Resource resource_widget);
        // Trying to distinguish between stream started and process started, after ads are skipped & co.
        // "just started" streaming provider was started, but not yet the real video stream.
        public signal void stream_just_started (RunningPlayer running_player);
        // "started" video stream is started.
        public signal void stream_started (RunningPlayer running_player);
        public signal void std_out (string std_out, RunningPlayer running_player);
        public signal void std_error (string std_error, RunningPlayer running_player);

        // public abstract Models.RunningPlayer running_player { get; set; }

        public abstract async void init (IProviderPlugin provider_plugin, IPlayerPlugin player_plugin);

        public abstract async void play (Models.Resource resource, Widgets.Providers.Default.Resource resource_widget);

        protected abstract bool process_line (IOChannel channel, IOCondition condition, string stream_name, Models.RunningPlayer running_player, Widgets.Providers.Default.Resource resource_widget);

        /**
         * Plugin.
         */
        public abstract string name { get; set; }
        public abstract StreamingProviderPluginLoader streaming_provider_plugin_loader { get; set; }
        public abstract void registered (StreamingProviderPluginLoader loader);
        public abstract void activate ();
        public abstract void deactivate ();
    }
}
