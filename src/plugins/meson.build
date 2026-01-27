streamlink_plugin_deps = [
    dependency('gee-0.8'),
    dependency('gtk4'),
    dependency('json-glib-1.0'),
    dependency('libadwaita-1', version: '>= 1.6'),
]

lib_streamlink_gtk_plugin_player_vlc = shared_library(
    'streamlink_gtk_plugin_player_vlc',
    [
        lib_streamlink_gtk_plugins_resources,
        'players/vlc/vlc.vala',
        'players/vlc/vlc-settings.vala',
        'players/vlc/widgets/preferences-group.vala',
    ],
    vala_header: 'lib_streamlink_gtk_plugin_player_vlc.h',
    vala_vapi: vapi_dir / 'lib_streamlink_gtk_plugin_player_vlc.vapi',
    include_directories: headers_directories,
    vala_args: streamlink_gtk_vala_args,
    dependencies: streamlink_plugin_deps,
    link_with: lib_streamlink_gtk_shared_sources,
    install: true,
    install_dir: [true, true, true],
)

lib_streamlink_gtk_plugin_provider_twitch = shared_library(
    'streamlink_gtk_plugin_provider_twitch',
    [
        lib_streamlink_gtk_plugins_resources,
        'providers/twitch/models/api-end-point.vala',
        'providers/twitch/models/contents-id.vala',
        'providers/twitch/models/response.vala',
        'providers/twitch/twitch.vala',
        'providers/twitch/twitch-settings.vala',
        'providers/twitch/widgets/preferences-page.vala',
        'providers/twitch/widgets/sidebar-list-box-row.vala',
        'providers/twitch/widgets/welcome-window-contents.vala',
    ],
    vala_header: 'lib_streamlink_gtk_plugin_provider_twitch.h',
    vala_vapi: vapi_dir / 'lib_streamlink_gtk_plugin_provider_twitch.vapi',
    include_directories: headers_directories,
    vala_args: streamlink_gtk_vala_args,
    dependencies: streamlink_plugin_deps,
    link_with: lib_streamlink_gtk_shared_sources,
    install: true,
    install_dir: [true, true, true],
)

lib_streamlink_gtk_plugin_streaming_provider_streamlink = shared_library(
    'streamlink_gtk_plugin_streaming_provider_streamlink',
    [
        'streaming-providers/streamlink/streamlink.vala',
    ],
    vala_header: 'lib_streamlink_gtk_plugin_streaming_provider_streamlink.h',
    vala_vapi: vapi_dir / 'lib_streamlink_gtk_plugin_streaming_provider_streamlink.vapi',
    include_directories: headers_directories,
    vala_args: streamlink_gtk_vala_args,
    dependencies: streamlink_plugin_deps,
    link_with: lib_streamlink_gtk_shared_sources,
    install: true,
    install_dir: [true, true, true],
)
