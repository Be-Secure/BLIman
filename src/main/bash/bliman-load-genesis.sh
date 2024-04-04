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
				echo "export $key_save=$multi_values"
			fi
		fi
	done < "$HOME/tmp.sh"

	if ! grep "$key_save" "$source_file" 
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
	
	source_file="$BLIMAN_DIR/tmp/genesis_data.sh"
        
	__bliman_convert_yaml_to_sh "$genesis_data" "$source_file"

	[[ -f $tmp_genesis_file ]] && rm $tmp_genesis_file

	source $source_file
}

function __bli_load_genesis() {

	local Genesis_File_location="";

        if [ -z $BLIMAN_GENSIS_FILE_PATH ];then
              __bliman_echo_yellow  ""
              __bliman_echo_yellow  "======================================================================================================"
              __bliman_echo_yellow  " Genesis file path is not set using default locations."
              __bliman_echo_yellow  ""
              __bliman_echo_yellow  " default locations are present working direcotry OR BLIMAN installation directory."
              __bliman_echo_yellow  "======================================================================================================"
              __bliman_echo_yellow  ""
	else
	       __bliman_echo_yellow  "Using Genesis file path at $BLIMAN_GENSIS_FILE_PATH"	
              Genesis_File_location=$BLIMAN_GENSIS_FILE_PATH

	fi

	if [ -z $Genesis_File_location ];then
	   __bliman_echo_no_colour "Checking Genesis file at present working directory."
           PWD=`pwd`
	   default_genesis_file_name=beslab_genesis.yaml

           if [ -f $PWD/$default_genesis_file_name ];then
	      __bliman_echo_yellow "Genesis file $default_genesis_file_name is found at present workin direcotry." 	   
              Genesis_File_location=$PWD/$default_genesis_file_name
	   else
	      __bliman_echo_yellow "Genesis file not found at present working directory."
	      __bliman_echo_yellow "Checking Genesis file at $BLIMAN_DIR"

	      if [ -z $BLIMAN_DIR ];then
                 __bliman_echo_yellow "BLIMAN_DIR is not set. Checking Gensis file at default bliman directory."
		 if [ -f $HOME/.bliman/$default_genesis_file_name ];then
		    __bliman_echo_yellow  "Using Genesis file located at default location $HOME/.bliman/$default_genesis_file_name"	 
                    Genesis_File_location=$HOME/.bliman/$default_genesis_file_name
		 else
	             __bliman_echo_red  "======================================================================================================"
                     __bliman_echo_red  " Genesis file not found at default locations."
                     __bliman_echo_red  ""
                     __bliman_echo_red  " Populate the Genesis file to current location or default locations and try again."
                     __bliman_echo_red  "======================================================================================================"
		     return 1
	         fi
	      else
		  if [ -f $BLIMAN_DIR/$default_genesis_file_name ];then    
		     __bliman_echo_yellow  "Using Genesis file located at specified by BLIMMAN_DIR $HOME/.bliman/$default_genesis_file_name"
                     Genesis_File_location=$BLIMAN_DIR/$default_genesis_file_name 
	          else
		     __bliman_echo_red  "======================================================================================================"
                     __bliman_echo_red  " Genesis file not found at $BLIMAN_DIR."
                     __bliman_echo_red  ""
                     __bliman_echo_red  " Populate the Genesis file at $PWD or $BLIMAN_DIR and try again."
                     __bliman_echo_red  "======================================================================================================"
                     return 1
                  fi
              fi

           fi
	fi
        __bliman_load_export_vars "$Genesis_File_location"
}
