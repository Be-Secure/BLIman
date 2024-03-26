#!/bin/bash

function __bli_reload()
{
	local genesis_file_name genesis_file_url
	genesis_file_name="beslab_genesis.yaml"
	genesis_file_url="$BLIMAN_LAB_URL/$genesis_file_name"

	if [[ -f "$HOME/$genesis_file_name" ]]; then

		__bliman_echo_yellow "Using genesis file found @ $HOME"
		export BLIMAN_GENSIS_FILE_PATH="$HOME/$genesis_file_name"
		__bliman_echo_yellow "Setting genesis file path as $BLIMAN_GENSIS_FILE_PATH"
	else
		__bliman_echo_yellow "Using default genesis file @ $genesis_file_url"
		export BLIMAN_GENSIS_FILE_PATH="$BLIMAN_DIR/tmp/$genesis_file_name"
		__bliman_echo_yellow "Setting genesis file path as $BLIMAN_GENSIS_FILE_PATH"
		__bliman_check_genesis_file_available "$genesis_file_url" || return 1
		__bliman_get_genesis_file "$genesis_file_url" "$BLIMAN_GENSIS_FILE_PATH"
	fi
	if ! __bliman_load_export_vars "$BLIMAN_GENSIS_FILE_PATH"
	then

		__bliman_echo_red "Something went wrong"
	else
		__bliman_echo_green "Done"
	fi
}
