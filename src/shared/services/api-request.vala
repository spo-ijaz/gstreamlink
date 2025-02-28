/* api-request.vala
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

using Soup;
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Services {

    public errordomain ApiRequestError {
        FAILED_REQUEST,
    }

    public class ApiRequest : Object {

        public signal void got_error (int error_code, string error_message);

        public SList<RequestHeader> default_request_headers;
        public string api_base_url { private get; construct; }

        private Session session;

        construct {
            this.session = new Session ();
            this.default_request_headers = new SList<Models.RequestHeader> ();
        }

        public ApiRequest (string api_base_url) {
            Object (
                    api_base_url: api_base_url
            );
        }

        public async string ? get_request_async (string uri, bool log_response = false) {

            try {

                Message message = new Message ("GET", this.api_base_url + uri);
                this.set_default_request_headers (message);

                Bytes message_bytes = yield this.session.send_and_read_async (message, Priority.DEFAULT, null);

                if (message.get_status () != Soup.Status.OK) {

                    throw new ApiRequestError.FAILED_REQUEST (@"Failed Request. HTTP Status: $(message.get_status())");
                }

                unowned uint8[] data = message_bytes.get_data ();
                if (log_response) {

                    print ("\n\n-------------------------------------------------\n");
                    print ((string) data);
                    print ("\n-------------------------------------------------\n\n");
                }

                return (string) data;
            } catch (Error error) {

                warning ("error: %s", error.message);
                this.got_error (error.code, error.message);
            }

            return null;
        }

        private void set_default_request_headers (Message message) {

            this.default_request_headers.@foreach ((request_header) => {

                message.get_request_headers ().append (request_header.name, request_header.value);
            });
        }
    }
}
