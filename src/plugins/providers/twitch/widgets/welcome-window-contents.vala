/* welcome-window-contents.vala
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
using StreamlinkGtk.Interfaces.Providers;

namespace StreamlinkGtk.Widgets.Providers.Twitch {

    class WelcomeWindowContents : IWelcomeWindowContents, Bin {

        construct {

            var box = new Gtk.Box (Orientation.VERTICAL, 6);
            box.halign = Gtk.Align.CENTER;
            box.valign = Gtk.Align.CENTER;

            var picture = new Gtk.Picture.for_resource ("/org/gnome/gstreamlink/plugins/providers/twitch/logo.png");
            picture.set_size_request (154, 250); 
            
            // "COVER" will zoom the image to cover the area without distortion
            // "CONTAIN" will show the whole image ensuring it fits inside
            // "FILL" will stretch it (can distort)
            picture.content_fit = Gtk.ContentFit.CONTAIN; 

            box.append (picture);

            var button = new Gtk.Button () {
                label = "Authenticate with Twitch",
                margin_top = 20,
                css_classes = { "suggested-action" }
            };

            button.clicked.connect (() => {
                this.login_button_clicked ();
            });

            box.append (button);

            this.child = box;
        }

        public WelcomeWindowContents () {
            Object ();
        }
    }
}
