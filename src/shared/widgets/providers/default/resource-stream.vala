/* resource-stream.vala
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

    public class ResourceStream : Resource {

        private Label label_started_at;
        private Label label_viewers_count;

        construct {

            Builder builder = new Builder.from_resource ("/org/gnome/gitlab/spoijaz/streamlinkgtk/shared/widgets/providers/default/resource-stream.ui");
            this.label_started_at = builder.get_object ("label_started_at") as Label;
            this.label_viewers_count = builder.get_object ("label_viewers_count") as Label;

            Box box_started_at = builder.get_object ("box_started_at") as Box;
            Box box_play = builder.get_object ("box_play") as Box;
            SplitButton split_button_play = builder.get_object ("split_button_play") as SplitButton;
            Box box_viewers_count = builder.get_object ("box_viewers_count") as Box;

            this.grid_options.attach (box_viewers_count, 0, 0, 1, 1);
            this.grid_options.attach (box_play, 1, 0, 1, 1);
            this.grid_options.attach (box_started_at, 2, 0, 1, 1);


            split_button_play.clicked.connect (() => {

                this.play_button_clicked (this.resource);
            });
        }

        public ResourceStream () {
            Object ();
        }

        public void initialize_from_stream (Models.ResourceStream resource_stream) {

            base.initialize (resource_stream);

            this.label_started_at.label = "  " + resource_stream.elapsed_time;
            this.label_viewers_count.label = "  " + resource_stream.viewers_count.to_string ();
        }
    }
}
