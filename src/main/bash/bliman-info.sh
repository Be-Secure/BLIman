#!/bin/bash

__bli_info() {

    # bli info plugin <plugin name>
    local plugin_name=$1
    local plugin_version=$2
    local installed_plugin=false
    
    if [[ -d $BLIMAN_PLUGINS_DIR/$plugin_name ]] 
    then
        installed_plugin=true
        source "$BLIMAN_PLUGINS_DIR/$plugin_name/$plugin_version/beslab-$plugin_name-$plugin_version-plugin.sh"
    else
        __bliman_get_remote_plugin "$plugin_name" "$plugin_version"
    fi

    __beslab_plugininfo_"$plugin_name"
    if [[ "$installed_plugin" == "true" ]]
    then
        __bliman_echo_yellow "Plugin $plugin_name $plugin_version is installed in your system."
    else
        __bliman_echo_yellow "Plugin $plugin_name $plugin_version is available to install."
    fi
}

function __bliman_get_remote_plugin() {

    local plugin_name=$1
    local plugin_version=$2
    local plugin_url="$BLIMAN_PLUGINS_REPO/"
}