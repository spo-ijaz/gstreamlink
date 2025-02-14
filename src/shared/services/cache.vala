/* cache.vala
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

namespace StreamlinkGtk.Services {

    public class Cache : Object {

        private static Cache _cache;

        public static unowned Cache get_default () {

            if (_cache == null) {

                _cache = new Cache ();
            }

            return _cache;
        }

        private string cache_dir;

        private string thumbnails_cache_dir;

        public string thumbnails_streams_cache_dir { get; construct; }

        public string thumbnails_channels_cache_dir { get; construct; }

        public string thumbnails_vod_cache_dir { get; construct; }

        construct {

            this.cache_dir = Environment.get_user_cache_dir () + "/" + Environment.get_application_name ();
            this.thumbnails_cache_dir = this.cache_dir + "/thumbnails";
            this.thumbnails_streams_cache_dir = this.thumbnails_cache_dir + "/streams";
            this.thumbnails_channels_cache_dir = this.thumbnails_cache_dir + "/channels";
            this.thumbnails_vod_cache_dir = this.thumbnails_cache_dir + "/vod";

            DirUtils.create_with_parents (this.thumbnails_streams_cache_dir, 0774);
            DirUtils.create (this.thumbnails_channels_cache_dir, 0774);
            DirUtils.create (this.thumbnails_vod_cache_dir, 0774);
        }


        public Cache () {
            Object ();
        }

        /**
         * @param cache_ttl cache ttl in seconds.
         */
        public async void get_file_from_uri_async (string src_uri, string dest_path, uint cache_ttl, out bool exists) {

            try {
                bool download = true;
                File dest_file = File.new_for_path (dest_path);

                // No cache ttl.
                if (cache_ttl == 0 && dest_file.query_exists ()) {

                    download = false;
                } else if (dest_file.query_exists ()) {

                    FileInfo file_info = dest_file.query_info ("time::created", FileQueryInfoFlags.NONE);
                    DateTime now = new DateTime.now ();

                    if ((now.to_unix () - file_info.get_creation_date_time ().to_unix ()) > cache_ttl) {

                        download = true;
                    } else {

                        download = false;
                    }
                }

                if (download == true) {

                    File src_file = File.new_for_uri (src_uri);
                    debug ("Downloading %s -> %s", src_file.get_uri (), dest_file.get_path ());

                    exists = yield src_file.copy_async (dest_file, GLib.FileCopyFlags.OVERWRITE, Priority.DEFAULT);
                } else {

                    exists = true;
                }
            } catch (Error error) {

                warning ("error: %s", error.message);
                exists = false;
            }
        }
    }
}
