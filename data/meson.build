desktop_file = i18n.merge_file(
    input: streamlink_gtk_app_id + '.desktop.in',
    output: streamlink_gtk_app_id + '.desktop',
    type: 'desktop',
    po_dir: '../po',
    install: true,
    install_dir: get_option('datadir') / 'applications',
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
    test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
    input: streamlink_gtk_app_id + '.metainfo.xml.in',
    output: streamlink_gtk_app_id + '.metainfo.xml',
    po_dir: '../po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo',
)

appstreamcli = find_program('appstreamcli', required: false, disabler: true)
test(
    'Validate appstream file',
    appstreamcli,
    args: ['validate', '--no-net', '--explain', appstream_file],
)

install_data(
    [
        streamlink_gtk_app_id + '.gschema.xml',
        streamlink_gtk_app_id + '.preferences.interface.gschema.xml',
        streamlink_gtk_app_id + '.preferences.players.gschema.xml',
        streamlink_gtk_app_id + '.preferences.providers.gschema.xml',
        streamlink_gtk_app_id + '.preferences.streaming-providers.gschema.xml',
        # plugins        
        streamlink_gtk_app_id + '.plugins.players.vlc.gschema.xml',
        streamlink_gtk_app_id + '.plugins.providers.twitch.gschema.xml',
    ],
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
)

install_data(
    'python/streamlink_gtk_twitch_oauth_receive.py',
)

compile_schemas = find_program('glib-compile-schemas', required: false, disabler: true)
test(
    'Validate schema file',
    compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()],
)

subdir('icons')
subdir('ui')
