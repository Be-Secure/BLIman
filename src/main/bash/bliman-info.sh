#!/bin/bash

__bli_info() {

    # bli info plugin <plugin name> <version>
    local type=$1
    local plugin_name=$2
    local plugin_version=$3

    if [[ ( -n $type ) && ( $type == "plugin" ) ]]
    then
        
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
    fi
}

function __bliman_check_plugin_exists() {
    local plugin_url=$1
    local plugin_url_exists
    plugin_url_exists=$(curl -s -o /dev/null -I -w "%{http_code}" "$plugin_url")
    if [[ "$plugin_url_exists" == "200" ]]
    then
        return 0
    else
        return 1
    fi
}

function __bliman_get_remote_plugin() {

    local plugin_name=$1
    local plugin_version=$2
    local plugin_repo
    local plugin_branch
    plugin_repo=$(echo "$BLIMAN_PLUGINS_REPO" | cut -d "/" -f 5)
    plugin_branch=$(echo "$BLIMAN_PLUGINS_REPO" | cut -d "/" -f 6)
    # https://raw.githubusercontent.com/Be-Secure/BeSLab-Plugins/refs/heads/main/OIAB-buyer-app/0.0.1/beslab-OIAB-buyer-app-0.0.1-plugin.sh
    local plugin_url="https://raw.githubusercontent.com/$BLIMAN_NAMESPACE/$plugin_repo/refs/heads/$plugin_branch/$plugin_name/$plugin_version/beslab-$plugin_name-$plugin_version-plugin.sh"
    __bliman_check_plugin_exists "$plugin_url"
    if [[ "$?" != "0" ]]
    then
         __bliman_echo_red "Could not find plugin $plugin_name $plugin_version"
         __bliman_echo_no_colour ""
         __bliman_echo_no_colour "Please check the plugin name and version"
         return 1
    fi
    __bliman_secure_curl "$plugin_url" > "$BLIMAN_DIR/tmp/$plugin_name-$plugin_version-plugin.sh"
    
    source "$BLIMAN_DIR/tmp/$plugin_name-$plugin_version-plugin.sh"

}