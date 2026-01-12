/* resource.vala
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
using StreamlinkGtk.Services;

namespace StreamlinkGtk.Widgets.Providers.Default {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/shared/widgets/providers/default/resource.ui")]

    public class Resource : Bin {

        [GtkChild]
        public unowned Grid grid;
        [GtkChild]
        public unowned Picture picture;
        [GtkChild]
        public unowned Label label_title;
        [GtkChild]
        public unowned Label label_subtitle;
        [GtkChild]
        public unowned Box box_options;
        [GtkChild]
        public unowned Grid grid_options;
        [GtkChild]
        public unowned Adw.Spinner spinner;

        public signal void play_button_clicked (Models.Resource resource);
        public signal void stop_button_clicked (Models.Resource resource);

        public Models.Resource resource { get; private set; }

        private Cache cache;

        construct {

            this.cache = Cache.get_default ();
        }

        public Resource () {
            Object ();
        }

        public void initialize (Models.Resource resource) {

            this.resource = resource;
            this.label_title.label = resource.title;
            if (resource.title_css_classes != null) {

                this.label_title.set_css_classes (resource.title_css_classes.data);
            }

            this.label_subtitle.label = resource.subtitle;
            if (resource.subtitle != "") {

                this.has_tooltip = true;
                this.tooltip_text = resource.subtitle;
                this.label_subtitle.margin_bottom = 10;
            }

            this.cache.get_file_from_uri_async.begin (resource.thumbnail.url, resource.thumbnail.path, resource.thumbnail.cache_ttl, (obj, res) => {

                bool exists;
                this.cache.get_file_from_uri_async.end (res, out exists);

                if (exists == true) {

                    this.grid.remove (this.spinner);
                    this.picture.width_request = resource.thumbnail.width;
                    this.picture.height_request = resource.thumbnail.height;
                    this.picture.set_filename (resource.thumbnail.path);
                }
            });
        }

        public void stream_just_started () {}

        public void stream_stopped () {
            debug ("Resource::stream_stopped - par la");
        }
    }
}
