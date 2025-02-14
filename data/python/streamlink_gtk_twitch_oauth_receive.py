# This script is used to create tiny webserver that receives an OAuth callback
# as GNOME does not provide a way for extensions to do that.
# gnome-online-accounts has no interface for that, neither does the shell.
# This is minimal implementation for what is needed to do OpenAuth without a client secret.
# We need the browser as the token is passed in the url fragment.
# AUTHOR: Mario Wenzel
# LICENSE: GPL3.0

from http.server import *;
from urllib.parse import *;
import sys;
import os.path;

twitch_authentication_done = """<html>
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
"""

authentication_done = """<html>
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
"""

class handler(BaseHTTPRequestHandler):

    def log_requests(self):
        pass

    def do_GET(self):

        print(self.path)
        
        if self.path == '/':
            # initial call from twitch
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()

            self.wfile.write(twitch_authentication_done.encode())
            
        elif self.path.startswith('/tokens'):
            # our own call
            code = parse_qs(urlparse(self.path).query)['access_token'][0]
            open(sys.argv[1], 'w').write(code)

            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.end_headers()

            self.wfile.write(authentication_done.encode())
            sys.exit(0)

HTTPServer(('', 3000), handler).serve_forever()
