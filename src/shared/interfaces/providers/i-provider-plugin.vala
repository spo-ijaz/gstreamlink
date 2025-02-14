/* i-provider.vala
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
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models;
using StreamlinkGtk.Models.Providers;
using StreamlinkGtk.Services;

namespace StreamlinkGtk.Interfaces.Providers {

    public interface IProviderPlugin : Object {

        // Emitted when request is done and json properly parsed.
        public signal void got_contents ();
        public signal void got_api_error (Toast toast);
        public signal void make_oauth_login ();

        // `position+1` of the item in the provider drop down.
        public abstract uint id { get; }
        public abstract string name { get; }
        public abstract bool user_login_available { get; }
        public abstract bool user_login_mandatory { get; }
        public abstract ProviderUser? provider_user { get; set; }
        public abstract string authorize_url { get; set; }
        public abstract string redirect_uri { get; }
        public abstract IScrolledWindowContents scrolled_window_contents { get; set; }
        // Configuration
        public abstract PreferencesPage preferences_page { get; set; }

        /**
         * Plugin.
         */
        public abstract ProviderPluginLoader provider_plugin_loader { get; set; }
        public abstract void registered (ProviderPluginLoader loader);
        public abstract void activate ();
        public abstract void deactivate ();

        /**
         * This method is called when OAuth is completed, with provider user info.
         * So you can initialize, if you want, a class that you will have to use to perform requests on the provider API.
         */
        public abstract void initialize_api_request ();

        /**
         * Fetch provider user info from provider API.
         */
        public abstract async bool update_provider_user_info_async (ProviderUser provider_user);
        public abstract async void get_side_bar_list_box_rows_async (out Array<ISideBarListBoxRow> list_box_rows);

        /**
         * It has to initialize the scrolled windows content's content.
         */
        public abstract async void get_contents_async (ContentsSelector contents_selector, out Contents contents);

        /**
         * The scrolled_window_contents should already contains the current Contents, so the Provider handle it directly.
         */
        public abstract async void get_next_contents_async ();

        /**
         * Streming provider plugin.
         */
        public abstract string get_extra_args_for_streaming_provider(IStreamingProviderPlugin streaming_provider);
    }
}
