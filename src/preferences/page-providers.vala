/* page--providers.vala
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
using Gtk;
using StreamlinkGtk.Settings;
using StreamlinkGtk.Preferences;
using StreamlinkGtk.Controllers;
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Preferences {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/widgets/preferences/page-providers.ui")]

    public class PageProviders : PreferencesPage {

        [GtkChild]
        public unowned Adw.ComboRow combo_row_provider;
        [GtkChild]
        public unowned SignalListItemFactory combo_row_provider_factory;

        public ProviderPluginController provider_plugin_controller { get; construct; }

        private AppSettings store;

        construct {


            // Default  provider
            //
            this.combo_row_provider.set_model (this.provider_plugin_controller.list_store_plugin_providers);

            this.store = AppSettings.get_default ();

            // Twitch as default.
            PluginProvider startup_plugin_provider = this.provider_plugin_controller.list_store_plugin_providers.get_item (0) as PluginProvider;
            uint startup_provider_id = this.store.get_uint ("startup-provider-id") > 0 ? this.store.get_uint ("startup-provider-id") : 1;

            for (uint position = 0; position <= this.provider_plugin_controller.list_store_plugin_providers.get_n_items (); position++) {

                startup_plugin_provider = this.provider_plugin_controller.list_store_plugin_providers.get_item (position) as PluginProvider;
                if (startup_plugin_provider.id == startup_provider_id) {

                    //  startup_provider_found = true;
                    this.combo_row_provider.set_selected (position);
                    break;
                }
            }

            // Handle provider selection.
            this.combo_row_provider.notify.connect (this.combo_row_provider_notify_handler);
        }

        public PageProviders (ProviderPluginController provider_plugin_controller) {
            Object (provider_plugin_controller: provider_plugin_controller);
        }

        [GtkCallback]
        private void combo_row_provider_setup_handler (SignalListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            list_item.set_child (new Label (""));
        }

        [GtkCallback]
        private void combo_row_provider_bind_handler (SignalListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            if (list_item.child == null) {

                this.combo_row_provider_setup_handler (factory, list_item);
            }

            Label? label = list_item.child as Label;
            PluginProvider? plugin_provider = list_item.item as PluginProvider;

            if (label != null && plugin_provider != null) {

                label.set_text (plugin_provider.name);
            }
        }

        private void combo_row_provider_notify_handler (ParamSpec paramspec) {

            if (this.combo_row_provider.get_model () != null && this.combo_row_provider.get_model ().get_n_items () > 0 && paramspec.get_name () == "selected-item") {

                PluginProvider plugin_provider_selected = this.combo_row_provider.get_model ().get_item (this.combo_row_provider.get_selected ()) as PluginProvider;
                if (plugin_provider_selected != null) {

                    this.store.set_uint ("startup-provider-id", plugin_provider_selected.id);
                } else {

                    warning ("Unable to get selected provider");
                }
            }
        }

    }
}
