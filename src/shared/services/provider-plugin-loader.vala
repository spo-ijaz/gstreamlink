/* provider-plugin-loader.vala
 *
 * Copyright 2026 PORQUET Sébastien
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

using StreamlinkGtk.Interfaces.Providers;
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Services {

    public class ProviderPluginLoader : Object {

        [CCode (has_target = false)]
        private delegate Type RegisterPluginFunction (Module module);

        private IProviderPlugin[] provider_plugins = new IProviderPlugin[0];
        private PluginInfo[] provider_plugin_infos = new PluginInfo[0];

        public IProviderPlugin load (string path, string register_plugin_function_name) throws PluginLoaderError {

            if (Module.supported () == false) {

                throw new PluginLoaderError.NOT_SUPPORTED ("Plugins are not supported");
            }

            Module module = Module.open (path, ModuleFlags.LAZY);
            if (module == null) {
                throw new PluginLoaderError.FAILED (Module.error ());
            }

            void* function;
            module.symbol (register_plugin_function_name, out function);

            if (function == null) {

                throw new PluginLoaderError.NO_REGISTRATION_FUNCTION (register_plugin_function_name + " () not found");
            }

            RegisterPluginFunction register_plugin = (RegisterPluginFunction) function;
            Type type = register_plugin (module);

            if (type.is_a (typeof (IProviderPlugin)) == false) {

                throw new PluginLoaderError.UNEXPECTED_TYPE ("Unexpected plugin provider type");
            }

            PluginInfo provider_plugin_info = new PluginInfo (type, (owned) module);
            provider_plugin_infos += provider_plugin_info;

            IProviderPlugin provider_plugin = (IProviderPlugin) Object.new (type);
            provider_plugins += provider_plugin;
            provider_plugin.registered (this);

            return provider_plugin;
        }

        public void unload () {

            this.provider_plugins[0].deactivate ();
            this.provider_plugins[0] = null;
        }

        ~ProviderPluginLoader () {
            this.provider_plugin_infos[0].module.close ();
        }
    }
}
