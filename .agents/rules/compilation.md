---
trigger: always_on
---

# Project description

* GUI toolkit : GTK4 and lib-adwaita project
* Language : vala


# Description


Project handle :
* multiple video players. (implemented : vlc )
* muliple streaming / vod provider  (implemented: twitch )
* multiple streaming player (implemented : streamlink )

# Architecture of the project

* video players, streaming provider and streaming player are implemented as plugins ;
* there're 3 types of plugins : 
** video player (ex: vlc)
** streaming provider (ex:twitch)
** streaming player (ex: streamlink)
* plugins should implement interfaces, one interface by type of plugins

```
|- src
|  |- controllers      - classes to control the 3 types of plugins
|  |- models           - models only need by the main application
|  |- plugins
|  |  |- players            - on sub-directory by video player implementation
|  |  |- providers          - on sub-directory by streaming provider implementation 
|  |  `- streaming-provider - on sub-directory by streaming player
|  |  
|  |- preferences     - gui for application preferences and the 3 types of plugins
|  |- shared          - all class need by plugins and main application
|  |  |- interfaces   - interfaces that plugins should implement
|  |  |- models       - common models that plugin and application need
|  |  |- services     - services common to plugins and main applicattion
|  |  |- settings     - commomn settings, plugins and main application
|  |  `- widgets      - common widgets
|  |- widgets         - widgets only used by the main application, not the plugins
```



# Twitch integration

* API documentation available here : https://dev.twitch.tv/docs/api/


# Compilations and execution

## Compilation instructions

```bash
export G_MESSAGES_DEBUG=all
export GSETTINGS_SCHEMA_DIR=data 
export LD_LIBRARY_PATH=builddir/src/plugins

meson setup builddir -Dprofile=dev --wipe

ninja -C builddir/
```

## Execution instructions:
```bash
glib-compile-schemas ./data/ && ./builddir/src/org.gnome.gstreamlink
```