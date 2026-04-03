# gstreamlink

A minimalist client for multiple streaming / vod providers, targeting Gnome desktop environment, using [Streamlink](khttps://streamlink.github.io/) as backend to watch video with your favorite player.

Currently it supports only :
* streaming / vod providers : [twitch.tv](https://www.twitch.tv)
* video players : [vlc](https://www.videolan.org)


![image](https://gitlab.gnome.org/spo-ijaz/streamlink-gtk/-/raw/main/screenshots/twitch_start.png?ref_type=heads)

# Get the Twitch session id

Open the web-browser console (`F12`) and copy-past this command :
```javascript
document.cookie.split('; ').find(row => row.startsWith('auth-token=')).split('=')[1]
```
 

# Building from sources

## Fedora

```bash
dnf install -y meson gtk4-devel json-glib-devel libadwaita-devel libsoup3-devel libgee-devel vala vala-language-server
```

## Ubuntu & co

```bash
apt install -y meson valac libgtk-4-dev libgee-0.8-dev libjson-glib-dev libadwaita-1-dev libsoup-3.0-dev 

```

# Development

```bash
export G_MESSAGES_DEBUG=all
export GSETTINGS_SCHEMA_DIR=data 
export LD_LIBRARY_PATH=builddir/src/plugins

meson setup builddir -Dprofile=dev --wipe

clear &&  ninja -C builddir/ && glib-compile-schemas ./data/ && ./builddir/src/org.gnome.gstreamlink

```

# Production

```bash
meson setup builddir_prod -Dprofile=prod --prefix=/usr --wipe
ninja -C builddir_prod
sudo ninja -C builddir_prod install
```
