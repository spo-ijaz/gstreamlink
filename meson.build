project(
    'org.gnome.gstreamlink',
    ['c', 'vala'],
    version: '0.0.1',
    meson_version: '>= 0.62.0',
    default_options: [
        'warning_level=2',
        'werror=false',
    ],
)

# Application ID
streamlink_gtk_app_id = 'org.gnome.gstreamlink'

# Main dependencies
i18n = import('i18n')
gnome = import('gnome')

# Add our custom VAPI dir
vapi_dir = meson.current_source_dir() / 'vapi'

streamlink_gtk_vala_args = [
    '--pkg', 'app-config',
]

add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

valac = meson.get_compiler('vala')
headers_directories = [
    include_directories('.'),
    include_directories('./src/shared'),
    include_directories('./src/plugins'),
]

# Configuration
app_conf = configuration_data()
app_conf.set_quoted('APP_ID', streamlink_gtk_app_id)
app_conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
app_conf.set_quoted('G_LOG_DOMAIN', meson.project_name())
app_conf.set_quoted('PACKAGE_NAME', meson.project_name())
app_conf.set_quoted('PACKAGE_STRING', meson.project_name())
app_conf.set_quoted('PACKAGE_VERSION', meson.project_version())
app_conf.set_quoted('VERSION', meson.project_version())
app_conf.set_quoted('PROFILE', get_option('profile'))
configure_file(output: 'app-config.h', configuration: app_conf)

subdir('data')
subdir('src/shared')
subdir('src/plugins')
subdir('src')
subdir('po')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
    update_desktop_database: true,
)
