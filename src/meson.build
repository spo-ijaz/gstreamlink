streamlink_gtk_sources += [
    'main.vala',
    'application.vala',
    'window.vala',

    'controllers/player-plugin-controller.vala',
    'controllers/provider-plugin-controller.vala',
    'controllers/streaming-provider-plugin-controller.vala',

    'models/plugin.vala',
    'models/plugin-player.vala',
    'models/plugin-provider.vala',
    'models/plugin-streaming-provider.vala',

    'preferences/page-streaming-providers.vala',
    'preferences/app-preferences.vala',
    'preferences/provider-preferences.vala',

    'widgets/drop-down-plugin-providers.vala',
    'widgets/menu-button-provider-user.vala',
    'widgets/sidebar-list-box.vala',
]

streamlink_gtk_deps = [
    dependency('gtk4'),
    dependency('gio-2.0'),
    dependency('gee-0.8'),
    dependency('gmodule-2.0'),
    dependency('json-glib-1.0'),
    dependency('libadwaita-1', version: '>= 1.6'),
    # https://mesonbuild.com/Vala.html#libraries-without-pkgconfig-files
    meson.get_compiler('vala').find_library('posix'),
]

executable(
    meson.project_name(),
    streamlink_gtk_sources,
    include_directories: headers_directories,
    vala_args: streamlink_gtk_vala_args,
    dependencies: streamlink_gtk_deps,
    install: true,
    link_with: [
        # Shared library
        lib_streamlink_gtk_shared_sources,
        # Players
        lib_streamlink_gtk_plugin_player_vlc,
        # Streaming providers
        lib_streamlink_gtk_plugin_streaming_provider_streamlink,
        # Live/VOD Providers
        lib_streamlink_gtk_plugin_provider_twitch,
    ],
)
