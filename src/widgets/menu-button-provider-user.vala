/* menu-button-provider-user.vala
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
using Gtk;
using StreamlinkGtk.Controllers;

namespace StreamlinkGtk.Widgets {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/widgets/menu-button-provider-user.ui")]

    public class MenuButtonProviderUser : Adw.Bin {

        public ProviderPluginController provider_plugin_controller { private get; construct; }

        [GtkChild]
        public unowned MenuButton menu_button;

        private Menu menu_model;
        private MenuItem item_status_login;
        private MenuItem item_login_logout;
        private MenuItem item_preferences;

        construct {

            this.item_status_login = new MenuItem ("Not connected", null);
            this.item_login_logout = new MenuItem ("_Login", "app.provider-login-logout");
            this.item_preferences = new MenuItem ("_Preferences", "app.provider-preferences");

            this.menu_model = new Menu ();
            this.menu_button.set_menu_model (this.menu_model);
            
            this.provider_plugin_controller.provider_user_updated.connect (provider_user_updated_handler);
        }

        public MenuButtonProviderUser (ProviderPluginController provider_plugin_controller) {
            Object (provider_plugin_controller: provider_plugin_controller);
        }

        private void provider_user_updated_handler (Models.ProviderUser provider_user) {

            this.menu_model.remove_all ();
            this.menu_model.append_item (this.item_preferences);

            if (provider_user.is_logged == true) {

                this.item_status_login.set_label ("@" + provider_user.username);
                this.item_login_logout.set_label ("Logout");

                this.menu_model.append_item (this.item_status_login);
                this.menu_model.append_item (this.item_login_logout);
            } else {

                this.item_status_login.set_label ("_Not logged");
                this.item_login_logout.set_label ("Login");

                this.menu_model.append_item (this.item_status_login);
                this.menu_model.append_item (this.item_login_logout);
            }
        }
    }
}
