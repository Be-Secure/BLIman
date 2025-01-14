#!/bin/bash

function __bliman_check_parameter_empty()
{
    local parameter=("$@")
    for param in "${parameter[@]}"; do
        if [[ -z "$param" ]]; then
            return 1
        fi
    done
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


function __bliman_download_plugin()
{
    local plugin_name plugin_version plugin_url plugin_repo plugin_branch plugin_path
    plugin_name="$1"
    plugin_version="$2"
    plugin_repo=$(echo "$BLIMAN_PLUGINS_REPO" | cut -d "/" -f 5)
    plugin_branch=$(echo "$BLIMAN_PLUGINS_REPO" | cut -d "/" -f 6)
    plugin_url="https://raw.githubusercontent.com/$BLIMAN_NAMESPACE/$plugin_repo/refs/heads/$plugin_branch/$plugin_name/$plugin_version/beslab-$plugin_name-$plugin_version-plugin.sh"
    __bliman_check_plugin_exists "$plugin_url"
    if [[ "$?" != "0" ]]
    then
         __bliman_echo_red "Could not find plugin $plugin_name $plugin_version"
         __bliman_echo_no_colour ""
         __bliman_echo_no_colour "Please check the plugin name and version"
         return 1
    fi
    plugin_path="$BLIMAN_PLUGINS_DIR/$plugin_name/$plugin_version"
    mkdir -p "$BLIMAN_PLUGINS_DIR/$plugin_name/$plugin_version"
    __bliman_echo_yellow "Downloading $plugin_name plugin_version $plugin_version"
    __bliman_secure_curl "$plugin_url" > "$plugin_path/$plugin_name-$plugin_version-plugin.sh"
    if [[ "$?" != "0" ]] 
    then
        return 1
    fi

}
