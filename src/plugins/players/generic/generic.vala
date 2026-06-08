using Adw;
using GLib;
using StreamlinkGtk.Services;
using StreamlinkGtk.Interfaces;
using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Players.Generic;
using StreamlinkGtk.Settings;

namespace StreamlinkGtk.PlayerProviders.Generic {

    public class GenericPlayer : Object, IPlayerPlugin {

        public string name { get; default = "Generic Player"; }
        private string _exec_name = "mpv";
        public string exec_name { 
            get { return _exec_name; }
        }

        public PlayerPluginLoader player_plugin_loader { get; set; }

        private PreferencesPlayersSettings player_store;
        private GenericSettings store;

        construct {
            this.store = GenericSettings.get_default ();
            this.player_store = PreferencesPlayersSettings.get_default ();

            this.store.changed["player-executable"].connect (() => {
                this._exec_name = this.store.get_string ("player-executable");
            });
            this._exec_name = this.store.get_string ("player-executable");
        }

        public Gtk.Widget get_preferences () {
            return new StreamlinkGtk.Widgets.Players.Generic.PreferencesGroup ();
        }

        public void activate () {
            debug ("Player plugin - Generic - activate\n");
        }

        public void deactivate () {
            debug ("Player plugin - Generic - deactivate\n");
        }

        public void registered (PlayerPluginLoader player_plugin_loader) {
            this.player_plugin_loader = player_plugin_loader;
        }

        public string get_extra_args_for_streaming_provider (IStreamingProviderPlugin streaming_provider) {

            string extra_args = this.store.get_string ("player-args");

            // Assuming user handles specific arguments manually via settings
            return extra_args;
        }
    }

    public Type register_plugin (Module module) {
        return typeof (GenericPlayer);
    }
}
