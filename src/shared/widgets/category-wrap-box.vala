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

    public class CategoryWrapBox : Adw.Bin {

        public Category category  { get; construct; }
        private WrapBox wrap_box;

        construct {
            
            this.wrap_box = new WrapBox ();

            Button category_tag = new Gtk.Button.with_label (this.category.name);
            category_tag.add_css_class ("flat");
            category_tag.add_css_class ("pill");
            category_tag.add_css_class ("tiny-category");


            this.wrap_box.append (category_tag);

            this.set_child (this.wrap_box);
        }

        public CategoryWrapBox (Category category) {
            Object (category: category);
        }
    }
}
