/* i-streaming-provider.vala
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


using Adw;
using Gtk;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models;
using StreamlinkGtk.Services;


namespace StreamlinkGtk.Interfaces.StreamingProviders {

    public interface IStreamingProviderPlugin : IExecOptions {

        public signal void player_started (RunningPlayer running_player);
        public signal void player_stopped (RunningPlayer running_player);

        public abstract Models.RunningPlayer running_player { get; set; }

        public abstract async void play (Models.Resource resource, IProviderPlugin provider_plugin);

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
