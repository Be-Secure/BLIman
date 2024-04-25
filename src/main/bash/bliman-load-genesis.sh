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
	
	source_file="$BLIMAN_DIR/etc/genesis_data.sh"
        
	__bliman_convert_yaml_to_sh "$genesis_data" "$source_file"

	[[ -f $tmp_genesis_file ]] && rm $tmp_genesis_file

	source $source_file

}

function __bli_load_genesis() {

	local Genesis_File_location="";

        if [ -z $BLIMAN_GENSIS_FILE_PATH ];then
              echo ""
              __bliman_echo_yellow  " Finding gnesis file at default locations i.e current directory or $HOME/.bliman directory"
	      echo ""
	else
	       __bliman_echo_yellow  "Using Genesis file path at $BLIMAN_GENSIS_FILE_PATH"	
              Genesis_File_location=$BLIMAN_GENSIS_FILE_PATH

	fi

	if [ -z $Genesis_File_location ];then
           PWD=`pwd`
	   default_genesis_file_name=genesis.yaml

           if [ -f $PWD/$default_genesis_file_name ];then
	      __bliman_echo_yellow  ""
              __bliman_echo_yellow  "======================================================================================================"
              __bliman_echo_yellow  " Using genesis file found at $PWD.                                                                    "
              __bliman_echo_yellow  "======================================================================================================"
              __bliman_echo_yellow  "" 	   
              Genesis_File_location=$PWD/$default_genesis_file_name
	   else
	      if [ -z $BLIMAN_DIR ];then
		 if [ -f $HOME/.bliman/$default_genesis_file_name ];then
	            __bliman_echo_yellow  ""
                    __bliman_echo_yellow  "======================================================================================================"
                    __bliman_echo_yellow  " Using genesis file present at $HOME/.bliman/$default_genesis_file_name.                              "
                    __bliman_echo_yellow  "======================================================================================================"
                    __bliman_echo_yellow  ""	 
                    Genesis_File_location=$HOME/.bliman/$default_genesis_file_name
		 else
	             __bliman_echo_red  "======================================================================================================"
                     __bliman_echo_red  " Genesis file not found at default locations.                                                         "
                     __bliman_echo_red  ""
                     __bliman_echo_red  " Provide the Genesis file to current location or at $HOME/.bliman and try again.                      "
                     __bliman_echo_red  "======================================================================================================"
		     return 1
	         fi
	      else
		  if [ -f $BLIMAN_DIR/$default_genesis_file_name ];then    
		    __bliman_echo_yellow  ""
                    __bliman_echo_yellow  "======================================================================================================"
                    __bliman_echo_yellow  " Using genesis file located at $BLIMAN_DIR/$default_genesis_file_name.                                "
                    __bliman_echo_yellow  "======================================================================================================"
                    __bliman_echo_yellow  ""

                     Genesis_File_location=$BLIMAN_DIR/$default_genesis_file_name 
	          else
		     __bliman_echo_red  "======================================================================================================"
                     __bliman_echo_red  " Genesis file not found at $BLIMAN_DIR.                                                               "
                     __bliman_echo_red  ""
                     __bliman_echo_red  " Provide the Genesis file at $PWD or $BLIMAN_DIR and try again.                                       "
                     __bliman_echo_red  "======================================================================================================"
                     return 1
                  fi
              fi

           fi
	fi
        __bliman_load_export_vars "$Genesis_File_location"
	

	__bliman_echo_green "Genesis file is loaded successfully!!"
	echo ""
        __bliman_echo_white "======================================================================================================"
        __bliman_echo_white "Lab name defined in genesis file is $BESMAN_LAB_NAME"
	__bliman_echo_white "Lab type set in genesis file is $BESMAN_LAB_TYPE"
	__bliman_echo_white "Lab deployment type defined in genesis file is $BESLAB_LAB_TYPE"
	__bliman_echo_white "Lab version defined in genesis file is $BESLAB_VERSION"
	__bliman_echo_white "Lab Name defined in genesis file is $BESMAN_LAB_NAME"
        __bliman_echo_white "======================================================================================================"
        echo ""
        echo ""
	__bliman_echo_yellow "======================================================================================================"
        __bliman_echo_yellow "  Execute \"bli initmode <modename>\" to set the beslab mode to install.                              "
	__bliman_echo_yellow "======================================================================================================"
        echo ""
}
