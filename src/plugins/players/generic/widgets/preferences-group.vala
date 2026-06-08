using Adw;
using Gtk;
using StreamlinkGtk.Players.Generic;

namespace StreamlinkGtk.Widgets.Players.Generic {

    [GtkTemplate (ui = "/org/gnome/gstreamlink/plugins/players/generic/preferences-widget.ui")]
    public class PreferencesGroup : Adw.PreferencesGroup {

        [GtkChild]
        public unowned Adw.EntryRow entry_player_executable;
        
        [GtkChild]
        public unowned Adw.EntryRow entry_player_args;

        private GenericSettings store;

        construct {
            this.store = GenericSettings.get_default ();
            this.store.bind ("player-executable", this.entry_player_executable, "text", SettingsBindFlags.DEFAULT);
            this.store.bind ("player-args", this.entry_player_args, "text", SettingsBindFlags.DEFAULT);
        }

        public PreferencesGroup () {
            Object ();
        }
    }
}
