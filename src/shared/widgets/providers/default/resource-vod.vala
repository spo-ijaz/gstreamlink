/* resource-vod.vala
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

    public class ResourceVod : Resource {

        private Label label_published_at;
        private Label label_duration;
        private Label label_viewers_count;

        construct {

            Builder builder = new Builder.from_resource ("/org/gnome/gitlab/spoijaz/streamlinkgtk/shared/widgets/providers/default/resource-vod.ui");
            this.label_published_at = builder.get_object ("label_published_at") as Label;
            this.label_duration = builder.get_object ("label_duration") as Label;
            this.label_viewers_count = builder.get_object ("label_viewers_count") as Label;

            Box box_viewers_count = builder.get_object ("box_viewers_count") as Box;
            Box box_published_info = builder.get_object ("box_published_info") as Box;
            Box box_play = builder.get_object ("box_play") as Box;
            SplitButton split_button_play = builder.get_object ("split_button_play") as SplitButton;

            this.grid_options.attach (box_viewers_count, 0, 0, 1, 1);
            this.grid_options.attach (box_play, 1, 0, 1, 1);
            this.grid_options.attach (box_published_info, 2, 0, 1, 1);

            split_button_play.clicked.connect (() => {

                this.play_button_clicked (this.resource);
            });
        }

        public ResourceVod () {
            Object ();
        }

        public void initialize_from_vod (Models.ResourceVod resource_vod) {

            base.initialize (resource_vod);

            this.label_published_at.label = "  " + resource_vod.published_at.format ("%a %d %b %Y");
            this.label_duration.label = "  " + resource_vod.duration.to_string ();
            this.label_viewers_count.label = "  " + resource_vod.viewers_count.to_string ();
            this.grid_options.attach (new ResourceVodPlayAtTime(resource_vod), 0, 2, 3, 1);
        }
    }
}
