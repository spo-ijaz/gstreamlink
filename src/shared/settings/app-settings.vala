/* app-settings.vala
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

using Gee;
using StreamlinkGtk;

namespace StreamlinkGtk.Settings {

    public class AppSettings : GLib.Settings {

        public uint current_provider_id { set; default = 1; private get; }

        private static AppSettings _app_settings;

        public static unowned AppSettings get_default () {

            if (_app_settings == null) {

                _app_settings = new AppSettings ();
            }

            return _app_settings;
        }

        public AppSettings () {
            Object (schema_id: AppConfig.APP_ID);
        }

        // If we don't find a ProviderUser for the current Provider, we return a new one, empty.
        // GVariant.type -> a(usssb)
        public Models.ProviderUser provider_user {

            owned get {

                uint provider_id = 0;
                string id = null;
                string username = null;
                string bearer_token = null;
                bool is_logged = false;

                Variant variant = this.get_value ("provider-user-configurations");
                VariantIter iter = variant.iterator ();
                while (iter.next ("(usssb)", &provider_id, &id, &username, &bearer_token, &is_logged)) {

                    if (provider_id == this.current_provider_id) {

                        // debug ("%u ----> %u", provider_id, this.current_provider_id);
                        debug ("Found provider user for provider id: %u, username: %s", provider_id, username);
                        return new Models.ProviderUser (provider_id, id, username, bearer_token, is_logged);
                    }
                }

                return new Models.ProviderUser (0, "", "", "", false);
            }

            set {

                uint provider_id = 0;
                string id = null;
                string username = null;
                string bearer_token = null;
                bool is_logged = false;
                bool provider_user_updated = false;

                VariantBuilder builder = new VariantBuilder (new VariantType ("a(usssb)"));
                Variant variant = this.get_value ("provider-user-configurations");
                VariantIter iter = variant.iterator ();
                while (iter.next ("(usssb)", &provider_id, &id, &username, &bearer_token, &is_logged)) {

                    // Default emtpy one from Gtk.Settings.
                    if (provider_id == 0) {

                        continue;
                    }

                    if (provider_id == this.current_provider_id || provider_id == 0) {

                        builder.add ("(usssb)", this.current_provider_id, value.id, value.username, value.bearer_token, value.is_logged);
                        provider_user_updated = true;
                    } else {

                        builder.add ("(usssb)", provider_id, id, username, bearer_token, is_logged);
                    }
                }

                if (provider_user_updated == false) {

                    builder.add ("(usssb)", this.current_provider_id, value.id, value.username, value.bearer_token, value.is_logged);
                }

                this.set_value ("provider-user-configurations", builder.end ());
            }
        }
    }
}
