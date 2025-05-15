# streamlink-gtk

A simple [Streamlink](khttps://streamlink.github.io/) GUI targeting Gnome desktop environment, built from the ground to support mutliple streaming providers, video players and live/vod providers.

Currently it supports only :
* streaming providers : [streamlink](https://streamlink.github.io/) - hence the name :)
* video providers : [twitch.tv](https://www.twitch.tv)
* video players : [vlc](https://www.videolan.org)
 

**WIP - It's not really ready for everyone, but the basics should works.**

# Todo
## Interface

- [x] - enable global notification
- [ ] implement search option.
- [ ] new user guidance.
- [ ] help for twitch provider, to get twitch session id from a web browser.
- [ ] cleanup UI.

## Twitch

- [x] handle notification of new streams
- [ ] start a VOD at a given time.
- [ ] handle Games section.
- [ ] handle search option in the different sections.
- [ ] option to follow / unfollow.
- [ ] why not implement the Twitch chat.

## VLC

- [ ] option on play button - start without sound.
- [ ] preference to start in minimal mode.
- [ ] preferences to set VLC window:  always-on-top, on all worskspace.


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


# Screenshots
## Twitch - followed stream

![image](https://gitlab.gnome.org/spo-ijaz/streamlink-gtk/-/raw/main/screenshots/twitch_start.png?ref_type=heads)
