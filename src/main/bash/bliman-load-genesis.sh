#!/bin/bash

function __bliman_get_genesis_file()
{
    local genesis_file_url 
    if [[ -f $HOME/beslab_genesis.yaml ]]; then
        __bliman_echo_yellow "Found genesis file at user home"
        export BLIMAN_GENSIS_FILE_PATH="$HOME/beslab_genesis.yaml"
    else
        __bliman_echo_yellow "Using default genesis file"
        exprot BLIMAN_GENSIS_FILE_PATH="$BLIMAN_DIR/tmp/beslab_genesis.yaml"
        genesis_file_url=https://raw.githubusercontent.com/Be-Secure/BeSLab/main/beslab_genesis.yaml
        [[ -f $BLIMAN_GENSIS_FILE_PATH ]] && touch "$BLIMAN_GENSIS_FILE_PATH"
        __bliman_secure_curl "$genesis_file_url" >> "$BLIMAN_GENSIS_FILE_PATH"
    fi
}

function __bliman_load_export_vars()
{
    local var value
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
    done < "$BLIMAN_GENSIS_FILE_PATH"
    
}

