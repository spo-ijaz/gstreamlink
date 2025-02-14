/* tools.vala
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

    class Tools : Object {

        public static string elapsed_time(DateTime from_date, DateTime to_date) {

            // debug("%s -> %s", from_date.to_string(), to_date.to_string());
            int64 date_diff_seconds = to_date.to_unix() - from_date.to_unix();
            int64 elapsed_minutes = 0;
            int64 elapsed_hours = 0;
            int64 elapsed_days = 0;

            string elapsed_time = "";

            // Days
            if (date_diff_seconds >= 86400) {

                elapsed_days = (date_diff_seconds / 3600) / 24;
                date_diff_seconds = date_diff_seconds - (elapsed_days * 86400);

                elapsed_time += elapsed_days.to_string() + "d ";
                // elapsed_time += elapsed_days.to_string() + " day" + (elapsed_days > 1 ? "s " : " ");
            }

            // Hours
            if (date_diff_seconds >= 3600) {

                elapsed_hours = (date_diff_seconds / 60) / 60;
                date_diff_seconds = date_diff_seconds - (elapsed_hours * 3600);

                elapsed_time += elapsed_hours.to_string() + "h ";
                // elapsed_time += elapsed_hours.to_string() + " hour" + (elapsed_hours > 1 ? "s " : " ");
            }

            // Minutes
            if (date_diff_seconds >= 60) {

                elapsed_minutes = date_diff_seconds / 60;
                date_diff_seconds = date_diff_seconds - (elapsed_minutes * 60);

                elapsed_time += elapsed_minutes.to_string() + "m ";
                // elapsed_time += elapsed_minutes.to_string() + " minute" + (elapsed_minutes > 1 ? "s " : " ");
            }

            elapsed_time += date_diff_seconds.to_string() + "s";
            // elapsed_time += date_diff_seconds.to_string() + " second" + (date_diff_seconds > 1 ? "s" : "");


            return elapsed_time;
        }
    }
}
