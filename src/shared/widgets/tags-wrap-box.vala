/* category-wrap-box.vala
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

namespace StreamlinkGtk.Widgets {

    public class TagsWrapBox : Adw.Bin {

        public Array<Tag> tags  { get; construct; }
        private WrapBox wrap_box;

        construct {

            this.wrap_box = new WrapBox ();

            foreach (Tag tag in this.tags) {

                Button tag_button = new Gtk.Button.with_label (tag.name);
                tag_button.add_css_class ("flat");
                tag_button.add_css_class ("pill");
                tag_button.add_css_class ("tiny-tag");

                this.wrap_box.append (tag_button);
            }


            this.set_child (this.wrap_box);
        }

        public TagsWrapBox (Array<Tag> tags) {
            Object (tags: tags);
        }
    }
}
