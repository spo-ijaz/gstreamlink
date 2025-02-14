# streamlink-gtk

A simple (Streamlink)[https://streamlink.github.io/] GUI targeting Gnome desktop environment, built from the ground to support mutliple streaming providers, video players and live/vod providers.

Currently it supports only :
* (streamlink)[https://streamlink.github.io/] - streaming provider - hence the name :)
* (twitch.tv)[https://www.twitch.tv] - video provider
* (vlc)[https://www.videolan.org] - video player
 
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

clear &&  ninja -C builddir/ && glib-compile-schemas ./data/ && ./builddir/src/org.gnome.gitlab.spoijaz.streamlink-gtk
```

# Production

```bash
meson setup builddir_prod -Dprofile=prod --prefix=/usr --wipe
ninja -C builddir_prod
sudo ninja -C builddir_prod install
```
