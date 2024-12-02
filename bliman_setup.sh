#!/bin/bash
BLIMAN_INSTALL_LOG_FILE="./bliman-install.log"
[[ ! -f $BLIMAN_INSTALL_LOG_FILE ]] && touch $BLIMAN_INSTALL_LOG_FILE

track_last_command() {
	last_command=$current_command
	current_command=$BASH_COMMAND
}

echo_failed_command() {
	local exit_code="$?"
	if [[ "$exit_code" != "0" ]]; then
		echo "'$last_command': command failed with exit code $exit_code."
	fi
}

bliman_setup_log() {
   datetime=$(date)
   while IFS= read -r line; do
     echo "$datetime : $line" >> $BLIMAN_INSTALL_LOG_FILE
   done
}

function bliman_setup_echo() {

        case $1 in
		red)
			color="31m"
			;;
		yellow)
			color="33m"
			;;
		white)
			color="1m"
			;;
		green)
			color="32m"
			;;
		cyan)
			color="36m"
			;;
		*)
			echo "$2"
			return 0
			;;
	esac
        echo -e "\033[1;$color$2\033[0m"
        echo $2 > bliman_setup_log
	return 0
}

function bliman_setup_download ()
{
    default_repo_url='https://github.com/'
    default_repo_namespace='Be-Secure'
    default_repo_name='BLIman'
    bliman_install_location="$HOME/.bliman"
    bliversion="$1"
    PWD=$(pwd)

    [[ ! -d $PWD/tmp ]] && mkdir tmp
    rm -rf $PWD/tmp/*

    tmp_location=$PWD/tmp

    if [ -z $BLIMAN_NAMESPACE ];then
      export BLIMAN_NAMESPACE="Be-Secure" 
    fi	    

    which jq 2>&1>>$BLIMAN_INSTALL_LOG_FILE

    if [ xx"$?" != xx"0" ];then
	bliman_setup_echo "yellow" "Installing JQ for JSON response readings."    
        sudo apt-get install jq -y 2>&1>>$BLIMAN_INSTALL_LOG_FILE
    fi

    if [ -z $1 ];then
       #bliman_setup_echo "yellow" "Get the BLIman latest release info from Be-Secure."
       response=$(curl --silent "https://api.github.com/repos/$BLIMAN_NAMESPACE/BLIman/releases/latest")

       if [[ $response == *"message"*"Not Found"* ]];then
             bliman_setup_echo "red" "BeSLab release version is not found."
             bliman_setup_echo "red" "Please check the namespace and try again."
             bliman_setup_echo "red" "Exiting..."
             return 1
       else
             bliversion=$(echo "$response" | jq -r '.tag_name')
       fi
    elif [ "$1" == "dev" ];then
	     bliman_setup_echo "yellow" "Get the BLIman latest release info from Be-Secure for development."
             response=$(curl --silent "https://api.github.com/repos/$BLIMAN_NAMESPACE/BLIman/releases/latest")
	     if [[ $response == *"message"*"Not Found"* ]];then
               bliman_setup_echo "red" "BeSLab release version is not found."
               bliman_setup_echo "red" "Please check the namespace and try again."
               bliman_setup_echo "red" "Exiting..."
               return 1
             else
               bliversion=$(echo "$response" | jq -r '.tag_name')
	       bliversion=$bliversion"-dev"
             fi
    else
	    bliversion="$1"
    fi
    
    if [ ! -z ${bliversion} ] && [[ ${bliversion} != *"-dev"* ]];then
	      bliman_setup_echo "yellow" "Downloading bliman release from Be-Secure."
              curl --silent -o $tmp_location/bliman-${bliversion}.zip --fail --location --progress-bar "${default_repo_url}/$BLIMAN_NAMESPACE/BLIman/archive/refs/tags/${bliversion}.zip" 2>&1>>$BLIMAN_INSTALL_LOG_FILE

              if [ -f  $tmp_location/bliman-${bliversion}.zip ];then
		 which unzip 2>&1>>$BLIMAN_INSTALL_LOG_FILE
                 if [ xx"$?" != xx"0" ];then
                      bliman_setup_echo "yellow" "Installing unzip."
                      sudo apt-get install unzip -y 2>&1>>$BLIMAN_INSTALL_LOG_FILE
                 fi     
                 unzip -qo $tmp_location/bliman-${bliversion}.zip -d $tmp_location 2>&1>>$BLIMAN_INSTALL_LOG_FILE
                 unset $BLIMAN_VERSION
                 export BLIMAN_VERSION="${bliversion}"
	      else
                bliman_setup_echo "red" "BLIman release version $bliversion is not found."
                bliman_setup_echo "red" "Please check the release version and try again."
                bliman_setup_echo "red" "Exiting..."
                return 1
              fi
	   
    elif [ ! -z ${bliversion} ] && [[ ${bliversion} == *"-dev"* ]];then
	       [[ -d $tmp_location/BLIman ]] && rm -rf $tmp_location/BLIman
	       if [ -z $(command -v git) ]; then
                  bliman_setup_echo "yellow" "git not found. Installing."
                  sudo apt-get install git -y 2>&1>>$BLIMAN_INSTALL_LOG_FILE  
	       fi
	       bliman_setup_echo "yellow" "Cloning bliman develop branch from Be-Secure."
               git clone --quiet -b develop https://github.com/Be-Secure/BLIman.git $tmp_location/BLIman 2>&1>>$BLIMAN_INSTALL_LOG_FILE
               unset $BLIMAN_VERSION
	       export BLIMAN_VERSION="${bliversion}"

    else
              bliman_setup_echo "red" "No valid latest release for BLIman found."
              bliman_setup_echo "red" "Please specify the release version and try again."
              bliman_setup_echo "red" "Exiting..."
              return 1
    fi
    return 0
}

function bliman_setup_check ()
{
   
	if [ -d "$BLIMAN_DIR/bin/" ]; then
		bliman_setup_echo "red" ""
		bliman_setup_echo "red" "======================================================================================================"
		bliman_setup_echo "red" " You already have BLIMAN installed."
		bliman_setup_echo "red" " BLIMAN was found at:"
		bliman_setup_echo "red" ""
		bliman_setup_echo "red" "    ${BLIMAN_DIR}"
		bliman_setup_echo "red" ""
		bliman_setup_echo "red" " Use \"source bliman_setup remove\" to remove or \"source bliman_setup update\" to update. "
		bliman_setup_echo "red" "======================================================================================================"
		bliman_setup_echo "red" ""
		return 1
	fi
	return 0

}
function bliman_setup_install() {

	PWD=$(pwd)

	local tmp_location="$PWD/tmp"

	trap track_last_command DEBUG
	trap echo_failed_command EXIT
        
	if [ -z "$BLIMAN_DIR" ]; then
                export BLIMAN_DIR="$HOME/.bliman"
                export BLIMAN_DIR_RAW="$HOME/.bliman"
        else
                export BLIMAN_DIR_RAW="$BLIMAN_DIR"
        fi

	# Local variables
        bliman_src_folder="${BLIMAN_DIR}/src"
        bliman_tmp_folder="${BLIMAN_DIR}/tmp"
        bliman_ext_folder="${BLIMAN_DIR}/ext"
        bliman_etc_folder="${BLIMAN_DIR}/etc"
        bliman_var_folder="${BLIMAN_DIR}/var"
	bliman_log_folder="${BLIMAN_DIR}/log"
        bliman_candidates_folder="${BLIMAN_DIR}/candidates"
        bliman_config_file="${bliman_etc_folder}/config"
        bliman_bash_profile="${HOME}/.bash_profile"
        bliman_bashrc="${HOME}/.bashrc"
        bliman_zshrc="${ZDOTDIR:-${HOME}}/.zshrc"

        bliman_init_snippet=$(
                cat <<EOF
#THIS MUST BE AT THE END OF THE FILE FOR BLIMAN TO WORK!!!
export BLIMAN_DIR="$BLIMAN_DIR_RAW"
[[ -s "${BLIMAN_DIR_RAW}/bin/bliman-init.sh" ]] && source "${BLIMAN_DIR_RAW}/bin/bliman-init.sh"
EOF
        )

	# Create directory structure
        mkdir -p "$bliman_tmp_folder"
        mkdir -p "$bliman_ext_folder"
        mkdir -p "$bliman_etc_folder"
        mkdir -p "$bliman_var_folder"
        mkdir -p "$bliman_candidates_folder"
        mkdir -p "$bliman_log_folder"
        mkdir -p "$bliman_src_folder"
        [[ ! -f ${BLIMAN_DIR}/var/version ]] && touch ${BLIMAN_DIR}/var/version
        
	# Sanity checks
        #bliman_setup_check
        #[[ xx"$?" != xx"0" ]] && return 1   
     

	bliman_setup_echo "yellow" "Installing BLIman."

        if [ ! -d  $tmp_location/BLIman-${bliversion:1} ] && [ ! -d $tmp_location/BLIman ];then
           bliman_setup_echo "red" "Bliman not downloaded properly. Please try again."
	   return 1
	elif  [ -d $tmp_location/BLIman ];then
           #cp -r $tmp_location/BLIman/contrib/ "$BLIMAN_DIR"
           cp -r $tmp_location/BLIman/src/main/bash/* "$bliman_src_folder"
           cp -r $tmp_location/BLIman/candidates/* "$bliman_candidates_folder"
           mkdir -p "$BLIMAN_DIR/bin/"
           mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/"
           BLIMAN_CANDIDATES_CSV=$(cat "$tmp_location/BLIman/candidates.txt")
	   touch $bliman_var_folder/version
	   echo "${bliversion}" >> $bliman_var_folder/version

	else
           #cp -r $tmp_location/BLIman-${bliversion:1}/contrib/ "$BLIMAN_DIR"
           cp -r $tmp_location/BLIman-${bliversion:1}/src/main/bash/* "$bliman_src_folder"
           cp -r $tmp_location/BLIman-${bliversion:1}/candidates/* "$bliman_candidates_folder"
           mkdir -p "$BLIMAN_DIR/bin/"
           mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/"
	   BLIMAN_CANDIDATES_CSV=$(cat "$tmp_location/BLIman-${bliversion:1}/candidates.txt")
	   touch $bliman_var_folder/version
           echo "${bliversion}" >> $bliman_var_folder/version
        fi

	if [[ ! -z $BLIMAN_CANDIDATES_CSV ]];then
	   echo "$BLIMAN_CANDIDATES_CSV" >"${BLIMAN_DIR}/var/candidates"
	else
           bliman_setup_echo "red" "Bliman not downloaded. Please retry."
           bliman_setup_echo "red" "Exiting ..."
	   return 1
        fi

        touch "$bliman_config_file"
        echo "bliman_auto_answer=false" >>"$bliman_config_file"
        if [ -z "$ZSH_VERSION" -a -z "$BASH_VERSION" ]; then
                echo "bliman_auto_complete=false" >>"$bliman_config_file"
        else
                echo "bliman_auto_complete=false" >>"$bliman_config_file"
        fi
        touch "$bliman_config_file"
        {
                echo "bliman_auto_env=false"
                echo "bliman_auto_update=true"
                echo "bliman_beta_channel=false"
                echo "bliman_checksum_enable=true"
                echo "bliman_colour_enable=true"
                echo "bliman_curl_connect_timeout=7"
                echo "bliman_curl_max_time=10"
                echo "bliman_debug_mode=false"
                echo "bliman_insecure_ssl=false"
                echo "bliman_rosetta2_compatible=false"
                echo "bliman_selfupdate_feature=true"
        } >>"$bliman_config_file"
        echo "bliman_insecure_ssl=false" >> "$bliman_config_file"

	# clean up
	[[ -f $tmp_location/bliman-${BLIMAN_VERSION}.zip ]] && rm -rf $tmp_location/bliman-${BLIMAN_VERSION}.zip
        [[ -d $tmp_location/BLIman-${bliversion:1} ]] && rm -rf $tmp_location/BLIman-${bliversion:1}
	[[ -d $tmp_location/BLIman ]] && rm -rf $tmp_location/BLIman
	rm -rf $tmp_location
	echo ""
	
	touch "${bliman_bashrc}"
	if [[ -z $(grep 'bliman-init.sh' "$bliman_bashrc") ]]; then
	   echo -e "\n$bliman_init_snippet" >>"$bliman_bashrc"
	fi

	if [ -f  $BLIMAN_DIR/bin/bliman-init.sh ];then
	   source $BLIMAN_DIR/bin/bliman-init.sh  2>&1>>$BLIMAN_INSTALL_LOG_FILE
	   source ~/.bashrc 2>&1>>$BLIMAN_INSTALL_LOG_FILE
	   bliman_setup_echo "green" "BLIman version ${blimanversion} is installed at $BLIMAN_DIR successfully."
           bliman_setup_echo "green" "Execute following command to verify the installation:"
	   bliman_setup_echo "green" "   source $HOME/.bliman/bin/bliman-init.sh"
           bliman_setup_echo "green" "   bli help"
           bliman_setup_echo "green" ""
           return 0
	else
	   bliman_setup_echo "red" ""
	   bliman_setup_echo "red" "BLIman not able to install properly."
	   bliman_setup_echo "red" ""
	   bliman_setup_echo "red" "   Please refer log file at $BLIMAN_INSTALL_LOG_FILE"
	   return 1
	fi
        return 0
}

function bliman_get_genesis_file ()
{
  #[[ -z $1 ]] &&  bliman_setup_echo "yellow" "Genesis file path not provided. Using default genesis file."

  present_working_dir=`pwd`
  if [ ! -z $1 ];then
    filename=$(echo $1 | awk -F / '{print $NF}')
    filenamefirst=$(echo $1 | awk -F / '{print $1}')

    echo $filename | grep "genesis-*.*.yaml"
    if [ xx"$?" != xx"0" ];then
       echo $filename | grep "genesis*.*.yaml"
       if [ xx"$?" != xx"0" ];then
	    bliman_setup_echo "red" "Nod a valid genesis filename." && return 1
       fi
    fi

    filetype=$(echo $filename | cut -d'-' -f2 )
    [[ $filename != "genesis.yaml" ]] && [[ "$filetype" != "OSPO.yaml" ]] && [[ "$filetype" != "OASP.yaml" ]] && [[ "$filetype" != "AIC.yaml" ]] && bliman_setup_echo "red" "Nod a valid genesis filename." && return 1

    if [ "$filenamefirst" == "http" ] || [ "$filenamefirst" == "https" ];then
            fileisurl="true"
    fi

    if [ -z $fileisurl ];then
       [[ ! -f $1 ]] && bliman_setup_echo "red" "Genesis file not found at $1." && return 1
    fi
    genesis_file_name="genesis.yaml"
    if [ ! -f "$present_working_dir/genesis.yaml" ];then
       if [ -z $fileisurl ];then
	 cp  $1 "genesis.yaml"
       else
	  bliman_setup_echo "yellow" "Trying download the gensis file from URL $1"     
	  genpath=$1
	  response=$(curl --silent -o $genesis_file_name $genpath)
          if [[ $response == *"message"*"Not Found"* ]];then
             bliman_setup_echo "red" "Gensis file is not found at given gensis path $genpath."
             return 1
          fi
      fi
    else
      bliman_setup_echo "yellow" "Genesis file is already present at current directory. Backing up current genesis file and copying new one"
      if [ ! -f $present_working_dir/"genesis_backup.yaml" ];then
         if [ "$filename" != "genesis.yaml" ];then
	   mv $present_working_dir/"genesis.yaml" $present_working_dir/"genesis_backup.yaml"
	 else
           cp $present_working_dir/"genesis.yaml" $present_working_dir/"genesis_backup.yaml"
	 fi
      else
	 rm $present_working_dir/"genesis_backup.yaml"
	 if [ $filename != "genesis.yaml" ];then
           mv $present_working_dir/"genesis.yaml" $present_working_dir/"genesis_backup.yaml"
         else
           cp $present_working_dir/"genesis.yaml" $present_working_dir/"genesis_backup.yaml"
         fi
      fi
      if [ -z $fileisurl ];then
         cp  $1 "genesis.yaml"
       else
          bliman_setup_echo "yellow" "Trying download the genesis file from URL $1"
          genpath=$1
          response=$(curl --silent -o $genesis_file_name $genpath)
          if [[ $response == *"message"*"Not Found"* ]];then
             bliman_setup_echo "red" "Gensis file is not found at given gensis path $genpath."
             return 1
          fi
      fi
    fi
  else
    genesis_file_name="genesis.yaml"
  fi

  if [ -z $1 ] && [ ! -f $present_working_dir/$genesis_file_name ];then	  
     bliman_setup_echo "yellow" "Downloading default genesis file from Be-Secure."
     if [[ ${version}  == "dev" ]];then
         curl --silent -o $genesis_file_name https://raw.githubusercontent.com/Be-Secure/BeSLab/develop/$genesis_file_name
     else
         curl --silent -o $genesis_file_name https://raw.githubusercontent.com/Be-Secure/BeSLab/main/$genesis_file_name
     fi
  fi
  export BLIMAN_GENSIS_FILE_PATH="$present_working_dir/$genesis_file_name"
  return 0
}

bliman_setup_update ()
{
    bliman_setup_echo "red" "TODO -- Coming Soon !!"
    return 0
}


bliman_setup_remove ()
{
    bliman_setup_echo "red" "TODO -- Coming Soon !!"
    return 0
}

bliman_setup_help ()
{
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "================================================================="
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "BLIman is the command line utiltiy to install the BeSLab.        "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "================================================================="
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "bliman_setup is utility to install/ update / remove the BLIman   "
    bliman_setup_echo "white" "and download the required beslab genesis file to the current     "
    bliman_setup_echo "white" "working directory.                                               "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "================================================================="
    bliman_setup_echo "white" "comands and usage"
    bliman_setup_echo "white" "================================================================="
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh install"
    bliman_setup_echo "white" "   [Install the BLIman and genesis file from Be-Secure community]                           "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh install --version v0.0.1 --genpath /opt/genesis-OASP.yaml                 "
    bliman_setup_echo "white" "   [Install the BLIman version 0.0.1 and genesis file present at /opt/genesis-OASP.yaml]    "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh install --version v0.0.1 --genpath https://raw.githubusercontent.com/Be-Secure/BLIman/develop/genesis-OSPO.yaml"
    bliman_setup_echo "white" "   [Install the BLIman version 0.0.1 and genesis file present at https://raw.githubusercontent.com/Be-Secure/BLIman/develop/genesis-OSPO.yaml]"
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh install --version v0.0.1 "
    bliman_setup_echo "white" "   [Install the BLIman version 0.0.1 and default genesis file from Be-Secure]"
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh remove"
    bliman_setup_echo "white" "   [Remove the BLIman installed] "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh update"
    bliman_setup_echo "white" "   [updates the BLIman to higher version if available.] "
    bliman_setup_echo "white" ""
    return 0
}
#### MAIN STARTS HERE
opts=()
args=()

[[ "$1" != "install" ]] && [[ "$1" != "remove" ]] && [[ "$1" != "update" ]] && echo "Not a valid command." && bliman_setup_help
command="$1"
shift
unset bliver
unset genesis_path
while [[ -n "$1" ]]; do
  case "$1" in
        --version)
	   shift
	   bliver="$1"
           ;;
	--genpath)
           shift
	   genesis_path="$1"
	   ;;
        *) 
	   bliman_setup_echo "red" "Not a valid command." && bliman_setup_help
	   ;;
  esac
  shift
done

case $command in
     install)
       bliman_setup_check 
       if [ xx"$?" != xx"0" ];then
          return 1
       fi
       [[ -z $bliver ]] && bliman_setup_echo "yellow" "No specific BLiman version is defined. Installing latest from repository." && ! bliman_setup_download && return 1
       [[ ! -z $bliver ]] && bliman_setup_echo "yellow" "Downloading BLIman version $bliver" && ! bliman_setup_download $bliver && return 1
       [[ -z $genesis_path ]] && bliman_setup_echo "yellow" "No Genesis path is provided doanloading the default genesis file from Be-Secure." && ! bliman_get_genesis_file && return 1
       [[ ! -z $genesis_path ]] && bliman_setup_echo "yellow" "Downloading Genesis file at $genesis_path" && ! bliman_get_genesis_file $genesis_path && return 1

       bliman_setup_install
       ;;
     remove)
       bliman_setup_remove && bliman_setup_echo "red"  "Working on it. Not available yet"; bliman_setup_help
       ;;
     update)
       bliman_setup_update && bliman_setup_echo "red"  "Coming Soon."; bliman_setup_help
       ;;
     *)
        bliman_setup_echo "red" "Not a valid bliman setup command\n" && bliman_setup_help
        ;;
esac
