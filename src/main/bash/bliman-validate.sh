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
#

function __bli_validate() {

    local type="$1"
    local plugin_name="$2"
    local plugin_version="$3"
    local plugin_path="$BLIMAN_PLUGINS_DIR/$plugin_name/$plugin_version/beslab-$plugin_name-$plugin_version-plugin.sh"

    __bliman_check_parameter_empty "$type" "$plugin_name" "$plugin_version"
    if [[ $? -ne 0 ]]; then
        __bliman_echo_red "Error: Missing argument"
        __bli_help_validate
        return 1
    fi

    if [[ "$type" == "plugin" ]]; then

        __bliman_check_plugin_installed "$plugin_name" "$plugin_version" "$plugin_path" || return 1
        source "$plugin_path"
        __beslab_validate_"$plugin_name"
        if [[ $? -eq 0 ]]; 
        then
            __bliman_echo_green "Validation completed successfully"
        else
            __bliman_echo_red "Validation completed with errors"
        fi
    fi

}

function __bliman_check_plugin_installed() {
    local plugin_name="$1"
    local plugin_version="$2"
    local plugin_path="$3"
    if [[ ! -f "$plugin_path" ]]; then
        __bliman_echo_red "Error: Plugin $plugin_name $plugin_version is not installed"
        return 1
    fi
}