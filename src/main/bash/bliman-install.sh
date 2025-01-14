#!/bin/bash

#
#   Copyright 2023 BeS Community
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.



function __bli_install(){
    # bli install plugin <plugin_name> <version>
    local type plugin_name plugin_version
    type="$1"
    plugin_name="$2"
    plugin_version="$3"

    __bliman_check_parameter_empty  "$plugin_name" "$type" "$plugin_version"
    if [[ $? -ne 0 ]];
    then
        __bliman_echo_red "Error: Missing argument"
        __bli_help_install
        return 1
    fi

    __bliman_download_plugin "$plugin_name" "$plugin_version" || return 1

    source $BLIMAN_PLUGINS_DIR/$plugin_name/$plugin_version/beslab-$plugin_name-$plugin_version-plugin.sh

    __beslab_install_"$plugin_name"

    if [[ $? -eq 0 ]] 
    then
        __bliman_echo_green "Plugin $plugin_name $plugin_version installed successfully"
    else
        __bliman_echo_red "Plugin $plugin_name $plugin_version could not be installed"
    fi

}