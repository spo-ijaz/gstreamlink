/* streaming-provider-plugin-loader.vala
 *
 * Copyright 2025 PORQUET Sébastien
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

using StreamlinkGtk.Interfaces.StreamingProviders;
using StreamlinkGtk.Models;

namespace StreamlinkGtk.Services {

    public class StreamingProviderPluginLoader : Object {

        [CCode (has_target = false)]
        private delegate Type RegisterPluginFunction (Module module);

        private IStreamingProviderPlugin[] streaming_provider_plugins = new IStreamingProviderPlugin[0];
        private PluginInfo[] streaming_provider_plugin_infos = new PluginInfo[0];

        public IStreamingProviderPlugin load (string path, string register_plugin_function_name) throws PluginLoaderError {

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

            if (type.is_a (typeof (IStreamingProviderPlugin)) == false) {

                throw new PluginLoaderError.UNEXPECTED_TYPE ("Unexpected plugin provider type");
            }

            PluginInfo provider_plugin_info = new PluginInfo (type, (owned) module);
            streaming_provider_plugin_infos += provider_plugin_info;

            IStreamingProviderPlugin streaming_provider_plugin = (IStreamingProviderPlugin) Object.new (type);
            streaming_provider_plugins += streaming_provider_plugin;
            streaming_provider_plugin.registered (this);

            return streaming_provider_plugin;
        }

        public void unload () {

            this.streaming_provider_plugins[0].deactivate ();
            this.streaming_provider_plugins[0] = null;
        }

        ~StreamingProviderPluginLoader () {
            this.streaming_provider_plugin_infos[0].module.close ();
        }
    }
}
