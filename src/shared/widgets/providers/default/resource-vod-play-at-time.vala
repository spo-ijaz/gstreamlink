/* resource-vod-play-at-time.vala
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
using Gtk;
using StreamlinkGtk.Services;

namespace StreamlinkGtk.Widgets.Providers.Default {

    public class ResourceVodPlayAtTime : Bin {

        private Scale scale;
        private Label time_label;

        public ResourceVodPlayAtTime (Models.ResourceVod resource_vod) {

            // Create vertical box to hold widgets
            var vbox = new Box (Orientation.VERTICAL, 5);
            // vbox.set_margin_top (2);
            // vbox.set_margin_bottom (1);
            // vbox.set_margin_start (2);
            // vbox.set_margin_end (2);

            this.scale = new Scale.with_range (Orientation.HORIZONTAL, 0, Tools.get_num_seconds_from_twitch_vod_duration (resource_vod.duration), 1);
            this.scale.set_draw_value (false);
            this.scale.set_digits (0);
            this.scale.set_hexpand (true);
            this.scale.set_valign (Align.CENTER);
            vbox.append (this.scale);

            this.time_label = new Label ("Start the VOD at: 00:00:00");
            vbox.append (time_label);

            this.scale.value_changed.connect (() => {

                resource_vod.start_at_seconds = (int) scale.get_value ();
                time_label.label = "Start the VOD at : " + Tools.format_to_hh_mm_dd (resource_vod.start_at_seconds);
            });

            set_child (vbox);
        }
    }
}
