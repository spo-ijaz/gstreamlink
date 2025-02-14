/* window.vala
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
using StreamlinkGtk.Controllers;
using StreamlinkGtk.StreamingProviders;
using StreamlinkGtk.Settings;
using StreamlinkGtk.Widgets;

namespace StreamlinkGtk {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/window.cmb.ui")]

    public class Window : Adw.ApplicationWindow {

        public StreamingProviderPluginController streaming_provider_controller { get; construct; }
        public ProviderPluginController provider_controller { get; construct; }
        public SideBarListBox side_bar_list_box { get; construct; }
        public MenuButtonProviderUser menu_button_provider_user { get; construct; }

        [GtkChild]
        public unowned NavigationSplitView split_view_navigation;
        [GtkChild]
        public unowned CssProvider css_provider;
        [GtkChild]
        public unowned ToolbarView toolbar_view_sidebar;
        [GtkChild]
        public unowned Adw.HeaderBar side_bar_header_bar;
        [GtkChild]
        public unowned Box sidebar_header_bar_box;
        [GtkChild]
        public unowned ScrolledWindow sidebar_scrolled_win;
        [GtkChild]
        public unowned ToolbarView toolbar_view_contents;      
        [GtkChild]
        public unowned Adw.HeaderBar header_bar;
        [GtkChild]
        public unowned Gtk.Box header_bar_provider_box;
        [GtkChild]
        public unowned Banner banner_login;
        [GtkChild]
        public unowned ViewStack view_stack;
        [GtkChild]
        public unowned ViewStackPage view_stack_page_contents;
        [GtkChild]
        public unowned ViewStackPage view_stack_page_running_players;
        [GtkChild]
        public unowned Overlay overlay;
        [GtkChild]
        public unowned Button button_load_more_results;
        [GtkChild]
        public unowned ToastOverlay toast_overlay;

        public  DropDownPluginProviders drop_down_plugin_providers;

        construct {

            css_provider.load_from_resource ("/org/gnome/gitlab/spoijaz/streamlinkgtk/styles.css");

            Gdk.Display display = Gdk.Display.get_default ();
            StyleContext.add_provider_for_display (display, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            
            // Initialize header bar
            this.drop_down_plugin_providers = new DropDownPluginProviders ();
            this.header_bar_provider_box.append (this.drop_down_plugin_providers);

            // Initialize main contents.
            this.toolbar_view_contents.set_content (view_stack);

            // Initialize main side bar contents selector.
            this.side_bar_list_box = new SideBarListBox (this.provider_controller);
            this.sidebar_scrolled_win.set_child (this.side_bar_list_box.list_box);

            // Add provider user menu.
            this.menu_button_provider_user = new MenuButtonProviderUser (this.provider_controller);
            this.header_bar_provider_box.append (this.menu_button_provider_user);

            // Initialize controllers.
            this.streaming_provider_controller = new StreamingProviderPluginController (view_stack_page_running_players);

            this.provider_controller.startup_initialization (this);

            AppSettings store = AppSettings.get_default ();

            // Save windows settings.
            store.bind ("window-width", this,
                        "default-width", SettingsBindFlags.DEFAULT);
            store.bind ("window-height", this,
                        "default-height", SettingsBindFlags.DEFAULT);
            store.bind ("window-is-maximized", this,
                        "maximized", SettingsBindFlags.DEFAULT);
        }

        public Window (Application application, ProviderPluginController provider_controller) {

            Object (
                    application: application,
                    provider_controller: provider_controller
            );
        }
    }
}
