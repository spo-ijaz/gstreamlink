/* drop-down-providers.vala
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
using StreamlinkGtk.Models;
using StreamlinkGtk.Settings;

namespace StreamlinkGtk.Widgets {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/widgets/drop-down-plugin-providers.ui")]

    public class DropDownPluginProviders : Bin {

        public signal void provider_changed (PluginProvider plugin_provider);

        [GtkChild]
        public unowned DropDown drop_down;

        private AppSettings store;

        construct {

            // User settings.
            this.store = AppSettings.get_default ();

            Expression expression = new PropertyExpression (typeof (PluginProvider), null, "name");
            this.drop_down.set_expression (expression);

            // Handle provider selection.
            this.drop_down.notify.connect (this.drop_down_notify_handler);
        }

        public DropDownPluginProviders () {
            Object ();
        }

        private void drop_down_notify_handler (ParamSpec paramspec) {

            if (this.drop_down.get_model () != null && this.drop_down.get_model ().get_n_items () > 0 && paramspec.get_name () == "selected-item") {

                PluginProvider plugin_provider_selected = this.drop_down.get_model ().get_item (this.drop_down.get_selected ()) as PluginProvider;
                if (plugin_provider_selected != null) {

                    this.provider_changed (plugin_provider_selected);
                } else {

                    warning ("Unable to get selected provider");
                }
            }
        }
    }
}
