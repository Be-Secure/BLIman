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
function __bliman_convert_yaml_to_sh()
{
	local genesis_data source_file
	genesis_data=$1
	source_file=$2

	while read -r key 
	do
		echo "$key" | sed "s/:/=/" | sed "s/ //g" >> "$HOME/tmp.sh"
	done <<< "$genesis_data" 

	multi_values=""
	multi_values_flag=false
	echo "#!/bin/bash" >> "$source_file"
	while read -r line 
	do
		if echo "$line" | grep -qe "^#" 
		then
			continue
		fi
		if [[ ( "$line" == "" ) || ( $line == "---" ) ]] 
		then
			continue
		fi
		key=$(echo "$line" | cut -d "=" -f 1)
		value=$(echo "$line" | cut -d "=" -f 2)
		if [ $multi_values_flag == true ] && ! echo "$key" | grep -qe "^-" 
		then
			multi_values_flag=false
			echo "$key_save=$multi_values" | sed "s/,//1" >> "$source_file"
			multi_values=""
		fi
		if [[ "$line" == "" ]]; then
			multi_values_flag=false
			echo "$key_save=$multi_values" | sed "s/,//1" >> "$source_file"
			multi_values=""
		fi
		if [[ $value == "" ]]; then
			multi_values_flag=true
			key_save=$key
			continue
		elif [[ $multi_values_flag == false ]] 
		then
			
			echo "$key=$value" >> "$source_file"
		fi
		if [[ $multi_values_flag == "true" ]] 
		then
			if echo "$line" | grep -qe "^-" 
			then
				value_2=$(echo "$line" | sed "s/-//1")
				multi_values+=",$value_2"
				continue

			else
				multi_values_flag=false
				echo "$key_save=$multi_values"
			fi
		fi
	done < "$HOME/tmp.sh"

	if ! grep "$key_save" "$source_file" 
	then
		echo "$key_save=$multi_values" | sed "s/,//1" >> "$source_file"
	fi

	[[ -f "$HOME/tmp.sh" ]] && rm "$HOME/tmp.sh"
}

function __bliman_load_export_vars() {
	local genesis_file_path source_file genesis_data
	__bliman_check_for_yq
	echo "Loading genesis file parameters"
	genesis_file_path=$1
	sed -i '/^$/d' "$genesis_file_path" # Delete empty lines
	genesis_data=$(<"$genesis_file_path")
	source_file="$BLIMAN_DIR/tmp/source.sh"
	__bliman_convert_yaml_to_sh "$genesis_data" "$source_file"
	source "$HOME/.bashrc"
}

# function __bliman_check_for_yq() {
# 	if [[ -z $(which yq) ]]; then
# 		echo "Installing yq"
# 		python3 -m pip install yq
# 	fi
# }

# function __bliman_load_export_vars() {
# 	local var value genesis_file_path tmp_file
# 	__bliman_check_for_yq
# 	__bliman_echo_yellow "Loading genesis file parameters"
# 	genesis_file_path=$1
# 	sed -i '/^$/d' "$genesis_file_path"
# 	genesis_data=$(<"$genesis_file_path")
# 	tmp_file="$BLIMAN_DIR/tmp/source.sh"
# 	[[ -f "$tmp_file" ]] && rm "$tmp_file"
# 	touch "$tmp_file"
# 	echo "#!/bin/bash" >>"$tmp_file"
# 	while read -r line; do
# 		[[ $line == "---" ]] && continue
# 		if echo "$line" | grep -qe "^#"; then
# 			continue
# 		elif echo "$line" | grep -qe "^BESLAB_"; then
# 			var=$(echo "$line" | cut -d ":" -f 1)
# 			value=$(yq ."$var" "$genesis_file_path" | sed 's/\[//; s/\]//; s/"//g' | tr -d '\n' | sed 's/ //g')
# 			unset "$var"
# 			echo "export $var=$value" >>"$tmp_file"
# 		fi
# 	done <<<"$genesis_data"

# }