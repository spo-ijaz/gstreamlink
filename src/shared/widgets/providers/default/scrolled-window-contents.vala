/* scrolled-window-contents.vala
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

namespace StreamlinkGtk.Widgets.Providers.Default {

    [GtkTemplate (ui = "/org/gnome/gitlab/spoijaz/streamlinkgtk/shared/widgets/providers/default/scrolled-window-contents.ui")]

    public class ScrolledWindowContents : IScrolledWindowContents, Bin {

        [GtkChild]
        public unowned GridView grid_view;
        [GtkChild]
        public unowned GLib.ListStore list_store { get; }
        [GtkChild]
        public unowned ScrolledWindow scrolled_window { get; }
        public Models.Contents contents { get; set; }
        public GLib.ListStore running_players { get; private set; }

        construct {

            this.grid_view.activate.connect ((position) => {

                Models.Resource resource = this.list_store.get_item (position) as Models.Resource;

                if (resource != null) {

                    debug ("---------> %s ", resource.title);
                    this.resource_clicked (resource);
                }
            });
        }

        public ScrolledWindowContents () {
            Object ();
        }

        public void init (GLib.ListStore running_players) {

            this.running_players = running_players;
        }

        public void provider_got_contents_handler (Models.Contents contents) {

            this.contents = null;
            this.contents = contents;
            this.list_store.remove_all ();

            foreach (Models.Resource resource in contents.resources) {

                this.list_store.append (resource);
            }
        }

        [GtkCallback]
        private void grid_view_signal_bind_handler (ListItemFactory factory, Object object) {

            ListItem list_item = object as ListItem;
            if (list_item == null) {

                return;
            }

            Models.Resource resource = list_item.item as Models.Resource;

            Models.RunningPlayer? running_player = null;
            bool already_running = false;
            uint n_items = this.running_players.get_n_items ();
            for (uint i = 0; i < n_items; i++) {

                running_player = (Models.RunningPlayer) this.running_players.get_item (i);
                if (running_player.content_url == resource.content_url) {

                    debug ("-------------------------------- ALREADY RUNNING: %s", resource.content_url);
                    already_running = true;
                    break;
                }
            }

            switch (resource.contents_type) {

            case Models.Resource.type.STREAM: {

                Models.ResourceStream resource_stream_model = list_item.item as Models.ResourceStream;
                resource_stream_model.running_player = running_player;
                
                ResourceStream resource_widget = new ResourceStream ();
                resource_stream_model.initialized = true;
                resource_widget.initialize_from_stream (resource_stream_model);
                resource_widget.play_button_clicked.connect ((resource_to_play) => {

                        this.resource_play_button_clicked (resource_to_play, resource_widget);
                    });
                resource_widget.stop_button_clicked.connect ((resource_to_play) => {

                        if(running_player != null) {

                            running_player.stop();
                        } else {

                            this.resource_stop_button_clicked (resource_to_play, resource_widget);
                        }
                    });
                list_item.child = resource_widget;

                if (already_running) {

                    resource_widget.stream_just_started ();
                }

                break;
            }

            case Models.Resource.type.CHANNEL: {

                Models.ResourceChannel resource_channel_model = list_item.item as Models.ResourceChannel;
                Resource resource_channel = new Resource ();
                resource_channel_model.initialized = true;
                resource_channel.initialize (resource_channel_model);
                list_item.child = resource_channel;
                break;
            }

            case Models.Resource.type.VOD: {

                Models.ResourceVod resource_vod_model = list_item.item as Models.ResourceVod;
                resource_vod_model.running_player = running_player;

                ResourceVod resource_widget = new ResourceVod ();
                resource_vod_model.initialized = true;
                resource_widget.initialize_from_vod (resource_vod_model);
                resource_widget.play_button_clicked.connect ((resource_to_play) => {

                        this.resource_play_button_clicked (resource_to_play, resource_widget);
                    });
                resource_widget.stop_button_clicked.connect ((resource_to_play) => {

                        if(running_player != null) {

                            running_player.stop();
                        } else {
                            
                            this.resource_stop_button_clicked (resource_to_play, resource_widget);
                        }
                    });
                list_item.child = resource_widget;

                if (already_running) {

                    resource_widget.stream_just_started ();
                }
                break;
            }

            default: {

                warning ("Unhandled resource type: %s", resource.contents_type.to_string ());
                break;
            }
            }
        }
    }
}
