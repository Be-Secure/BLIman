#!/usr/bin/env bash

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
        [[ ! -f $source_file ]] && touch $source_file
	echo "#!/bin/bash" > "$source_file"
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
			echo "export $key_save=$multi_values" | sed "s/,//1" >> "$source_file"
			multi_values=""
		fi
		if [[ "$line" == "" ]]; then
			multi_values_flag=false
			echo "export $key_save=$multi_values" | sed "s/,//1" >> "$source_file"
			multi_values=""
		fi
		if [[ $value == "" ]]; then
			multi_values_flag=true
			key_save=$key
			continue
		elif [[ $multi_values_flag == false ]] 
		then
			
			echo "export $key=$value" >> "$source_file"
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
				echo "export $key_save=$multi_values" | __bliman_log
			fi
		fi
	done < "$HOME/tmp.sh"

	if ! grep "$key_save" "$source_file" > /dev/null
	then
		echo "export $key_save=$multi_values" | sed "s/,//1" >> "$source_file"
	fi

	[[ -f "$HOME/tmp.sh" ]] && rm "$HOME/tmp.sh"
}

function __bliman_load_export_vars() {
	local genesis_file_path source_file genesis_data
	 __bliman_echo_no_colour  "Loading Genesis file ..."
	genesis_file_path=$1

        tmp_genesis_file=/tmp/tmp_genesis.yaml

	sed '/^$/d' "$genesis_file_path" > $tmp_genesis_file # Delete empty lines

	genesis_data=$(<"$tmp_genesis_file") #Load genesis data
	
	source_file="$BLIMAN_DIR/etc/genesis_data.sh"
        
	__bliman_convert_yaml_to_sh "$genesis_data" "$source_file"

	[[ -f $tmp_genesis_file ]] && rm $tmp_genesis_file

	source $source_file

}

function __bli_load_genesis() {

	local Genesis_File_location="";

	PWD=`pwd`
        default_genesis_file_name=genesis.yaml
	if [ ! -z $1 ] && [ ! -z $2 ];then
	   if [ xx"$1" == "--genesis_path" ];then
             Genesis_File_location=$2
           else
              __bliman_echo_red  "Invalid genesis load command"
	      return 1
	   fi
        else
           [[ -f "$PWD/$default_genesis_file_name" ]] && Genesis_File_location="$PWD/$default_genesis_file_name"
	   [[ -f "$HOME/.bliman/$default_genesis_file_name" ]] && Genesis_File_location="$HOME/.bliman/$default_genesis_file_name"
	fi

        filename=$(echo $Genesis_File_location | awk -F / '{print $NF}')
        filenamefirst=$(echo $Genesis_File_location | awk -F / '{print $1}')

        echo $filename | grep "genesis*.*.yaml"
        [[ xx"$?" != xx"0" ]] && __bliman_echo_red "Not a valid genesis filename." && return 1

	echo $filename | grep "genesis-*.*.yaml"
        if [ xx"$?" == xx"0" ];then
          filetype=$(echo $filename | cut -d'-' -f2 )
          [[ $filetype != "OSPO.yaml"]] && [[ $filetype != "OASP.yaml"]] && [[ $filetype != "AIC.yaml"]] && __bliman_echo_red "Nod a valid genesis filename." && return 1
	fi

        if [ $filenamefirst == "http" ] || [ $filenamefirst == "https" ];then
            fileisurl="true"
        fi

        if [ -z $fileisurl ];then
	    [[ ! -f $Genesis_File_location ]] && __bliman_echo_red "Genesis file not found at $Genesis_File_location." && return 1
            cp  $Genesis_File_location "genesis.yaml"
        else
            __bliman_echo_yellow "Trying download the gensis file from URL $1"
            
            response=$(curl --silent -o $default_genesis_file_name $Genesis_File_location)
            if [[ $response == *"message"*"Not Found"* ]];then
               __bliman_echo_red "Genesis file is not found at given gensis path $Genesis_File_location."
               return 1
            fi
        fi

	if [ -f $default_genesis_file_name ];then
          __bliman_load_export_vars "$default_genesis_file_name"
        else
	  __bliman_echo_red "Not able to download the genesis file."
	  return 1
	fi
	
	__bliman_echo_green "Genesis file is loaded successfully!!"
	echo ""
        __bliman_echo_white "======================================================================================================"
	__bliman_echo_white "Lab type set in genesis file is \"$BESMAN_LAB_TYPE\""
	__bliman_echo_white "Lab deployment type defined in genesis file is \"$BESLAB_LAB_TYPE\""
	__bliman_echo_white "Lab version defined in genesis file is \"$BESLAB_VERSION\""
	__bliman_echo_white "Lab Name defined in genesis file is \"$BESMAN_LAB_NAME\""
        __bliman_echo_white "======================================================================================================"
        echo ""
        echo ""
	__bliman_echo_yellow "======================================================================================================"
        __bliman_echo_yellow "  Execute \"bli initmode <modename>\" to set the beslab mode to install.                              "
	__bliman_echo_yellow "======================================================================================================"
        echo ""
}
