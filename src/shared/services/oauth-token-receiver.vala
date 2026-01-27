/* oauth-token-receiver.vala
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

using GLib;
using Soup;
using StreamlinkGtk.Interfaces.Providers;

namespace StreamlinkGtk.Services {

    public class OAuthTokenReceiver : Object {

        public signal void got_access_token (string access_token);
        public signal void failed_to_get_access_token ();

        public IProviderPlugin provider { get; construct; }
        public string name { get; construct; }

        private Soup.Server server;
        private MainLoop loop;

        private const string HTML_TWITCH_AUTH_DONE = """<html>
<head>
  <title>Streamlink GTK - OAuth-Process</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
</head>
<body>

<div class="d-flex flex-column min-vh-100 justify-content-center align-items-center">

  <div class="card" style="width: 18rem;">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Twitch_logo.svg/320px-Twitch_logo.svg.png" class="card-img-top" alt="twitch logo">
    <div class="card-body">
      <h3 class="card-title">Streamlink GTK</h3>
      <p class="card-text">
        You are now successfully authenticated with Twitch.<br/>
        Click the button below to complete the authentication process with Streamlink GTK.
      </p>
      <script>
        var tokens=document.location.hash.substring(1);
        document.write('<a href="/tokens?' + tokens + '" class="btn btn-primary">click here to finish the authentication process</a>');
      </script>
    </div>
  </div>
</div>

</div>

</body>
</html>
""";

        private const string HTML_AUTH_DONE = """<html>
<head>
  <title>Streamlink GTK - OAuth-Process</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
</head>
<body>

<div class="d-flex flex-column min-vh-100 justify-content-center align-items-center">

  <div class="card" style="width: 18rem;">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Twitch_logo.svg/320px-Twitch_logo.svg.png" class="card-img-top" alt="twitch logo">
    <div class="card-body">
      <h3 class="card-title">Streamlink GTK</h3>
      <p class="card-text">
        Ok, all good.<br/>
        You can close this page.
      </p>
    </div>
  </div>
</div>

</div>

</body>
</html>
""";

        public OAuthTokenReceiver (string name, IProviderPlugin provider) {
            Object (name: name, provider: provider);
        }

        public void run () {

            this.loop = new MainLoop ();

            this.start_http_server ();
            this.wait_before_opening_authorize_url.begin ();

            loop.run ();
        }

        private async void wait_before_opening_authorize_url () {

            GLib.Timeout.add (1000, () => {

                this.open_authorize_url ();
                return false;
            }, GLib.Priority.DEFAULT);
            yield;
        }

        private void start_http_server () {
            this.server = new Soup.Server ("server-header", "streamlink-gtk-oauth");
            this.server.add_handler ("/", this.http_handler);

            try {
                this.server.listen_local (3000, 0);
            } catch (Error e) {
                warning ("Failed to start HTTP server: %s", e.message);
                this.failed_to_get_access_token ();
                this.loop.quit ();
            }
        }

        private void http_handler (Soup.Server server, Soup.ServerMessage msg, string path, HashTable<string, string>? query) {
            msg.set_status (Soup.Status.OK, null);
            msg.get_response_headers ().append ("Content-Type", "text/html");

            if (path == "/") {
                msg.get_response_body ().append (Soup.MemoryUse.COPY, HTML_TWITCH_AUTH_DONE.data);
            } else if (path.has_prefix ("/tokens")) {
                if (query != null && query.contains ("access_token")) {
                    string access_token = query.get ("access_token");
                    debug ("Access token: %s", access_token);
                    this.got_access_token (access_token);
                } else {
                    warning ("No access token found in query");
                    this.failed_to_get_access_token ();
                }

                msg.get_response_body ().append (Soup.MemoryUse.COPY, HTML_AUTH_DONE.data);

                // Quit the loop after a short delay to allow the response to be sent
                Timeout.add (500, () => {
                    this.loop.quit ();
                    return false;
                });
            } else {
                msg.set_status (Soup.Status.NOT_FOUND, null);
            }
        }

        private void open_authorize_url () {

            try {

                Pid child_pid;
                Process.spawn_async ("/",
                                     { "xdg-open", this.provider.authorize_url },
                                     Environ.get (),
                                     SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                     null,
                                     out child_pid);

                ChildWatch.add (child_pid, (pid, status) => {
                    Process.close_pid (pid);
                });
            } catch (SpawnError spawn_error) {

                warning ("%s", spawn_error.message);
            }
        }
    }
}