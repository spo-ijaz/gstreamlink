namespace StreamlinkGtk.Players.Generic {

    public class GenericSettings : GLib.Settings {

        private static GenericSettings _generic_settings;

        public static unowned GenericSettings get_default () {

            if (_generic_settings == null) {

                _generic_settings = new GenericSettings ();
            }

            return _generic_settings;
        }

        public GenericSettings () {
            Object (schema_id: AppConfig.APP_ID + ".plugins.players.generic");
        }
    }
}
