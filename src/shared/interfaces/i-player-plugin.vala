/* i-player-plugin.vala
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

using Gtk;
using StreamlinkGtk.Interfaces;

namespace StreamlinkGtk.Interfaces.PlayerProviders {

    public interface IPlayerPlugin : IExecOptions {

        public abstract Widget get_preferences();

        /**
         * Plugin.
         */
         public abstract string name { get; set; }
         public abstract PlayerPluginLoader streaming_provider_plugin_loader { get; set; }
         public abstract void registered (PlayerPluginLoader loader);
         public abstract void activate ();
         public abstract void deactivate ();
    }
}
