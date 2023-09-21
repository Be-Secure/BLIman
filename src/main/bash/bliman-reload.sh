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

	

function __bliman_get_genesis_file() {
	local url default_genesis_file_path
	url=$1
	default_genesis_file_path=$2
	[[ -f "$default_genesis_file_path" ]] && rm "$default_genesis_file_path"
	touch "$default_genesis_file_path"
	__bliman_echo_yellow "Downloading genesis file"
	__bliman_secure_curl "$url" >>"$default_genesis_file_path"

}

function __bliman_check_for_yq() {
	if [[ -z $(which yq) ]]; then
		echo "Installing yq"
		python3 -m pip install yq
	fi
}

function __bliman_load_export_vars() {
	local var value genesis_file_path tmp_file
	__bliman_check_for_yq
	__bliman_echo_yellow "Loading genesis file parameters"
	genesis_file_path=$1
	sed -i '/^$/d' "$genesis_file_path"
	genesis_data=$(<"$genesis_file_path")
	tmp_file="$BLIMAN_DIR/tmp/source.sh"
	[[ -f "$tmp_file" ]] && rm "$tmp_file"
	touch "$tmp_file"
	echo "#!/bin/bash" >>"$tmp_file"
	while read -r line; do
		[[ $line == "---" ]] && continue
		if echo "$line" | grep -qe "^#"; then
			continue
		elif echo "$line" | grep -qe "^BESLAB_"; then
			var=$(echo "$line" | cut -d ":" -f 1)
			value=$(yq ."$var" "$genesis_file_path" | sed 's/\[//; s/\]//; s/"//g' | tr -d '\n' | sed 's/ //g')
			unset "$var"
			echo "export $var=$value" >>"$tmp_file"
		fi
	done <<<"$genesis_data"
	source "$HOME/.bashrc"
}