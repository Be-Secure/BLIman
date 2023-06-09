#!/bin/bash

function __bli_launch()
{
    local genesis_file_name genesis_file_url default_genesis_file_path
    genesis_file_name="beslab_genesis.yaml"
    genesis_file_url="$BLIMAN_LAB_URL/$genesis_file_name"
    
    [[ -z $BESLAB_MODE ]] && __bliman_echo_red "Stop!!! Please run the install command first" && return 1
    if [[ -f "$HOME/$genesis_file_name" ]]; then

        __bliman_echo_yellow "Genesis file found at $HOME"
        export BLIMAN_GENSIS_FILE_PATH="$HOME/$genesis_file_name"
    else
        export BLIMAN_GENSIS_FILE_PATH="$BLIMAN_DIR/tmp/$genesis_file_name"
        __bliman_check_genesis_file_available "$genesis_file_url" || return 1
        __bliman_get_genesis_file "$genesis_file_url" "$BLIMAN_GENSIS_FILE_PATH"
    fi
    __bliman_load_export_vars "$BLIMAN_GENSIS_FILE_PATH"

}


function __bliman_check_genesis_file_available()
{
    local url response
    url=$1
    response=$(curl --head --silent "$url" | head -n 1 | awk '{print $2}')
    if [ "$response" -eq 200 ]; then
        __bliman_echo_red "Could not find genesis file @ $url"
        return 1
    else
        __bliman_echo_white "Genesis file found"
    fi

}

function __bliman_get_genesis_file()
{
    local url default_genesis_file_path
    url=$1
    default_genesis_file_path=$2
    touch "$default_genesis_file_path"
    __bliman_secure_curl "$url" >> "$default_genesis_file_path"
    
}

function __bliman_load_export_vars()
{
    local var value genesis_file_path
    genesis_file_path=$1
    while read -r line 
    do
        [[ $line == "---" ]] && continue
        if echo "$line" | grep -qe "^BESLAB_"  
        then
            
            var=$(echo "$line" | cut -d ":" -f 1)
            value=$(echo "$line" | cut -d ":" -f 2 | sed "s/ //g")
            unset "$var"
            export "$var"="$value"
        fi
    done < "$genesis_file_path"
    
}


