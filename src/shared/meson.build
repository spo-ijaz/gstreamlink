streamlink_gtk_shared_deps = [
    dependency('gee-0.8'),
    dependency('gmodule-2.0'),
    dependency('gio-2.0'),
    dependency('gtk4'),
    dependency('libadwaita-1', version: '>= 1.6'),
    dependency('libsoup-3.0'),
]

lib_streamlink_gtk_shared_sources = shared_library(
    'streamlink_gtk_shared',
    [
        lib_streamlink_gtk_shared_resources,

        'interfaces/i-exec-options.vala',
        # 'interfaces/i-player-provider.vala',
        'interfaces/i-streaming-provider-plugin.vala',
        'interfaces/providers/i-scrolled-window-contents.vala',
        'interfaces/providers/i-provider-plugin.vala',
        'interfaces/providers/i-sidebar-list-bow-row.vala',

        # 'models/channel.vala',
        'models/contents.vala',
        'models/plugin-loader-error.vala',
        'models/plugin-info.vala',
        'models/provider-user.vala',
        'models/providers/contents-selector.vala',
        'models/providers/pagination-cursor.vala',
        'models/request-header.vala',
        'models/resource.vala',
        'models/resource-channel.vala',
        'models/resource-stream.vala',
        'models/resource-vod.vala',
        'models/running-player.vala',
        # 'models/stream.vala',
        'models/thumbnail.vala',

        'services/api-request.vala',
        'services/cache.vala',
        'services/oauth-token-receiver.vala',
        'services/provider-plugin-loader.vala',
        'services/streaming-provider-plugin-loader.vala',
        'services/tools.vala',

        'settings/app-settings.vala',
        'settings/preferences-providers-settings.vala',

        'streaming-provider.vala',

        'widgets/providers/default/resource.vala',
        'widgets/providers/default/resource-stream.vala',
        'widgets/providers/default/resource-vod.vala',
        'widgets/providers/default/scrolled-window-contents.vala',
    ],
    vala_header: 'lib_streamlink_gtk_shared.h',
    vala_vapi: vapi_dir / 'lib_streamlink_gtk_shared.vapi',
    include_directories: headers_directories,
    vala_args: streamlink_gtk_vala_args,
    dependencies: streamlink_gtk_shared_deps,
    install: true,
    install_dir: [true, true, true],
)
