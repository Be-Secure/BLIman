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
}

function infer_platform() {
	local kernel
	local machine

	kernel="$(uname -s)"
	machine="$(uname -m)"

	case $kernel in
	Linux)
		case $machine in
		i686)
			echo "linuxx32"
			;;
		x86_64)
			echo "linuxx64"
			;;
		armv6l)
			echo "linuxarm32hf"
			;;
		armv7l)
			echo "linuxarm32hf"
			;;
		armv8l)
			echo "linuxarm32hf"
			;;
		aarch64)
			echo "linuxarm64"
			;;
		*)
			echo "exotic"
			;;
		esac
		;;
	Darwin)
		case $machine in
		x86_64)
			echo "darwinx64"
			;;
		arm64)
			if [[ "$bliman_rosetta2_compatible" == 'true' ]]; then
				echo "darwinx64"
			else
				echo "darwinarm64"
			fi
			;;
		*)
			echo "darwinx64"
			;;
		esac
		;;
	MSYS* | MINGW*)
		case $machine in
		x86_64)
			echo "windowsx64"
			;;
		*)
			echo "exotic"
			;;
		esac
		;;
	*)
		echo "exotic"
		;;
	esac
}

function bliman_setup_download ()
{
    default_repo_url='https://github.com/'
    default_repo_namespace='Be-Secure'
    default_repo_name='BLIman'
    tmp_location="/tmp"
    bliman_install_location="$HOME/.bliman"

    bliversion="$1"

    if [ -z $BLIMAN_NAMESPACE ];then
      export BLIMAN_NAMESPACE="Be-Secure" 
    fi	    

    which jq 2>&1>>$BLIMAN_INSTALL_LOG_FILE

    if [ xx"$?" != xx"0" ];then
	bliman_setup_echo "yellow" "Installing JQ for JSON response readings."    
        sudo apt-get install jq -y
    fi

    if [ -z $1 ];then
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
             response=$(curl --silent "https://api.github.com/repos/$BLIMAN_NAMESPACE/BLIman/releases/latest")
	     bliversion=$(echo "$response" | jq -r '.tag_name')
	     bliversion=$bliversion"-dev" 
    else
	    bliversion="$1"
    fi
    
    if [ ! -z ${bliversion} ] && [[ ${bliversion} != *"-dev"* ]];then
              unset $BLIMAN_VERSION
              export BLIMAN_VERSION="${bliversion}"
              curl --silent -o $tmp_location/bliman-${bliversion}.zip --fail --location --progress-bar "${default_repo_url}/$BLIMAN_NAMESPACE/BLIman/archive/refs/tags/${bliversion}.zip" 2>&1>>$BLIMAN_INSTALL_LOG_FILE

              if [ -f  $tmp_location/bliman-${bliversion}.zip ];then
		 which unzip 2>&1>>$BLIMAN_INSTALL_LOG_FILE
                 if [ xx"$?" != xx"0" ];then
                      bliman_setup_echo "yellow" "Installing unzip."
                      sudo apt-get install unzip -y 2>&1>>$BLIMAN_INSTALL_LOG_FILE
                 fi     
                 unzip -qo $tmp_location/bliman-${bliversion}.zip -d $tmp_location 2>&1>>$BLIMAN_INSTALL_LOG_FILE
              else
                bliman_setup_echo "red" "BLIman release version $bliversion is not found."
                bliman_setup_echo "red" "Please check the release version and try again."
                bliman_setup_echo "red" "Exiting..."
                return 1
              fi
    elif [ ! -z ${bliversion} ] && [[ ${bliversion} == *"-dev"* ]];then
	       unset $BLIMAN_VERSION
               export BLIMAN_VERSION="${bliversion}"
	       [[ -d $tmp_location/BLIman ]] && rm -rf $tmp_location/BLIman
               git clone -b develop https://github.com/Be-Secure/BLIman.git $tmp_location/BLIman 2>&1>>$BLIMAN_INSTALL_LOG_FILE
    else
              bliman_setup_echo "red" "No valid latest release for BLIman found."
              bliman_setup_echo "red" "Please specify the release version and try again."
              bliman_setup_echo "red" "Exiting..."
              return 1
    fi
}

function bliman_setup_check ()
{
   
	if [ -d "$BLIMAN_DIR/bin/" ]; then
		echo "BLIMAN found."
		echo ""
		echo "======================================================================================================"
		echo " You already have BLIMAN installed."
		echo " BLIMAN was found at:"
		echo ""
		echo "    ${BLIMAN_DIR}"
		echo ""
		echo "======================================================================================================"
		echo ""
		exit 0
	fi

	echo "Looking for curl..."
	if ! command -v curl >>$BLIMAN_INSTALL_LOG_FILE; then
		echo "Not found."
		echo ""
		echo "======================================================================================================"
		echo " Please install curl on your system using your favourite package manager."
		echo ""
		echo " Restart after installing curl."
		echo "======================================================================================================"
		echo ""
		exit 1
	fi


	if [[ "$solaris" == true ]]; then
		echo "Looking for gsed..."
		if [ -z $(which gsed) ]; then
			echo "Not found."
			echo ""
			echo "======================================================================================================"
			echo " Please install gsed on your solaris system."
			echo ""
			echo " BLIMAN uses gsed extensively."
			echo ""
			echo " Restart after installing gsed."
			echo "======================================================================================================"
			echo ""
			exit 1
		fi
	else
		echo "Looking for sed..."
		if [ -z $(command -v sed) ]; then
			echo "Not found."
			echo ""
			echo "======================================================================================================"
			echo " Please install sed on your system using your favourite package manager."
			echo ""
			echo " Restart after installing sed."
			echo "======================================================================================================"
			echo ""
			exit 1
		fi
	fi

        echo "Looking for git..."
        if [ -z $(command -v git) ]; then
                        echo "Not found."
                        echo ""
                        echo "======================================================================================================"
                        echo " Please install git on your system using your favourite package manager."
                        echo ""
                        echo " Restart after installing git."
                        echo "======================================================================================================"
                        echo ""
                        exit 1
        fi

}
function bliman_setup_install() {

	local genesis_path force_flag
        local tmp_location="/tmp"

	trap track_last_command DEBUG
	trap echo_failed_command EXIT

	if [ ! -z $2 ] && [ "$2" != "dev" ];then
          
	    if [ ${2:0:1} == "v" ];then
	      bliversion=${2:1}
            else
              bliversion=${2}
	    fi

        elif [ ! -z ${BLIMAN_VERSION} ];then
	
	  if [ ${BLIMAN_VERSION:0:1} == "v" ];then
	    bliversion=${BLIMAN_VERSION:1}
	  elif [ ${BLIMAN_VERSION:0-3} == "dev" ];then
	     bliversion=${BLIMAN_VERSION:0-4}
	     export Is_Dev="true"
	  else
            bliversion=${BLIMAN_VERSION}
          fi
	else
		echo "Please provide BLIman version to install."
		echo "exiting .."
		return 1
	fi

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
        
	#[[ -d $BLIMAN_DIR ]] && rm -rf $BLIMAN_DIR/*

	# Create directory structure
        mkdir -p "$bliman_tmp_folder"
        mkdir -p "$bliman_ext_folder"
        mkdir -p "$bliman_etc_folder"
        mkdir -p "$bliman_var_folder"
        mkdir -p "$bliman_candidates_folder"
        mkdir -p "$bliman_log_folder"
        mkdir -p "$bliman_src_folder"
        [[ ! -f ${BLIMAN_DIR}/var/version ]] && touch ${BLIMAN_DIR}/var/version

        #DATE=$(date +"%Y-%m-%d-%k-%M")
        #logfilename=bliman-install-log-$DATE.log

        #createlogfile $bliman_log_folder $logfilename 2>&1 | bliman_setup_log
        #export BLIMAN_INSTALL_LOG_FILE="$bliman_log_folder/$logfilename"

	export BLIMAN_PLATFORM="$(infer_platform)"
	
	# OS specific support (must be 'true' or 'false').
	cygwin=false
	darwin=false
	solaris=false
	freebsd=false
	case "$(uname)" in
	CYGWIN*)
		cygwin=true
		;;
	Darwin*)
		darwin=true
		;;
	SunOS*)
		solaris=true
		;;
	FreeBSD*)
		freebsd=true
		;;
	esac

        # Sanity checks
        bliman_setup_check

	bliman_setup_echo "yellow" "Installing BLIman."
	echo ""
	echo ' BBBBBBBBBBBBBBBBB   LLLLLLLLLLL             IIIIIIIIIIMMMMMMMM               MMMMMMMM               AAA               NNNNNNNN        NNNNNNNN '
	echo ' B::::::::::::::::B  L:::::::::L             I::::::::IM:::::::M             M:::::::M              A:::A              N:::::::N       N::::::N '
	echo ' B::::::BBBBBB:::::B L:::::::::L             I::::::::IM::::::::M           M::::::::M             A:::::A             N::::::::N      N::::::N '
	echo ' BB:::::B     B:::::BLL:::::::LL             II::::::IIM:::::::::M         M:::::::::M            A:::::::A            N:::::::::N     N::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M::::::::::M       M::::::::::M           A:::::::::A           N::::::::::N    N::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M:::::::::::M     M:::::::::::M          A:::::A:::::A          N:::::::::::N   N::::::N '
	echo '   B::::BBBBBB:::::B   L:::::L                 I::::I  M:::::::M::::M   M::::M:::::::M         A:::::A A:::::A         N:::::::N::::N  N::::::N '
	echo '   B:::::::::::::BB    L:::::L                 I::::I  M::::::M M::::M M::::M M::::::M        A:::::A   A:::::A        N::::::N N::::N N::::::N '
	echo '   B::::BBBBBB:::::B   L:::::L                 I::::I  M::::::M  M::::M::::M  M::::::M       A:::::A     A:::::A       N::::::N  N::::N:::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M::::::M   M:::::::M   M::::::M      A:::::AAAAAAAAA:::::A      N::::::N   N:::::::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M::::::M    M:::::M    M::::::M     A:::::::::::::::::::::A     N::::::N    N::::::::::N '
	echo '   B::::B     B:::::B  L:::::L         LLLLLL  I::::I  M::::::M     MMMMM     M::::::M    A:::::AAAAAAAAAAAAA:::::A    N::::::N     N:::::::::N '
	echo ' BB:::::BBBBBB::::::BLL:::::::LLLLLLLLL:::::LII::::::IIM::::::M               M::::::M   A:::::A             A:::::A   N::::::N      N::::::::N '
	echo ' B:::::::::::::::::B L::::::::::::::::::::::LI::::::::IM::::::M               M::::::M  A:::::A               A:::::A  N::::::N       N:::::::N '
	echo ' B::::::::::::::::B  L::::::::::::::::::::::LI::::::::IM::::::M               M::::::M A:::::A                 A:::::A N::::::N        N::::::N '
        echo ""

        if [ ! -d  $tmp_location/BLIman-${bliversion} ] && [ ! -d $tmp_location/BLIman ];then
           bliman_setup_echo "red" "Bliman not downloaded. Please retry."
	   bliman_setup_echo "red" "Exiting ..."
	   return 1
	elif  [ -d $tmp_location/BLIman ];then
           cp -r $tmp_location/BLIman/contrib/ "$BLIMAN_DIR"
           cp -r $tmp_location/BLIman/src/main/bash/* "$bliman_src_folder"
           cp -r $tmp_location/BLIman/candidates/* "$bliman_candidates_folder"
           mkdir -p "$BLIMAN_DIR/bin/"
           mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/"
           BLIMAN_CANDIDATES_CSV=$(cat "$tmp_location/BLIman/candidates.txt")
	else
           cp -r $tmp_location/BLIman-${bliversion}/contrib/ "$BLIMAN_DIR"
           cp -r $tmp_location/BLIman-${bliversion}/src/main/bash/* "$bliman_src_folder"
           cp -r $tmp_location/BLIman-${bliversion}/candidates/* "$bliman_candidates_folder"
           mkdir -p "$BLIMAN_DIR/bin/"
           mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/"
	   BLIMAN_CANDIDATES_CSV=$(cat "$tmp_location/BLIman-${bliversion}/candidates.txt")
        fi

	if [[ ! -z $BLIMAN_CANDIDATES_CSV ]];then
	   echo "$BLIMAN_CANDIDATES_CSV" >"${BLIMAN_DIR}/var/candidates"
	else
           bliman_setup_echo "red" "Bliman not downloaded. Please retry."
           bliman_setup_echo "red" "Exiting ..."
	   return 1
        fi

        echo "Prime the config file..."
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

        if [[ $BLIMAN_PLATFORM == "windowsx64" ]]; then
                echo "bliman_insecure_ssl=true" >> "$bliman_config_file"
        else
                echo "bliman_insecure_ssl=false" >> "$bliman_config_file"
        fi

	# clean up
	[[ -f $tmp_location/bliman-${BLIMAN_VERSION}.zip ]] && rm -rf $tmp_location/bliman-${BLIMAN_VERSION}.zip
        [[ -d $tmp_location/BLIman-${bliversion} ]] && rm -rf $tmp_location/BLIman-${bliversion}
	[[ -d $tmp_location/BLIman ]] && rm -rf $tmp_location/BLIman
	echo ""
	
	echo "$bliversion" >"${BLIMAN_DIR}/var/version"
        if [ ! -z $Is_Dev ] && [ "$Is_Dev" == "true" ];then
           echo "Develop-Version" >> "${BLIMAN_DIR}/var/version"
	fi

	if [[ $darwin == true ]]; then
		touch "$bliman_bash_profile"
		if [[ -z $(grep 'bliman-init.sh' "$bliman_bash_profile") ]]; then
			echo -e "\n$bliman_init_snippet" >>"$bliman_bash_profile"
		fi
	else
		touch "${bliman_bashrc}"
		if [[ -z $(grep 'bliman-init.sh' "$bliman_bashrc") ]]; then
			echo -e "\n$bliman_init_snippet" >>"$bliman_bashrc"
		fi
	fi

	touch "$bliman_zshrc"
	if [[ -z $(grep 'bliman-init.sh' "$bliman_zshrc") ]]; then
		echo -e "\n$bliman_init_snippet" >>"$bliman_zshrc"
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

}

function bliman_get_genesis_file ()
{
  genesis_file_name="genesis.yaml"
  present_working_dir=`pwd`

  version=$1

  if [ ! -f $present_working_dir/$genesis_file_name ];then	  
           export BLIMAN_GENSIS_FILE_PATH="$present_working_dir/$genesis_file_name"
	   if [[ ${version}  == "dev" ]];then
             curl --silent -o $genesis_file_name https://raw.githubusercontent.com/Be-Secure/BeSLab/develop/$genesis_file_name
           else
	     curl --silent -o $genesis_file_name https://raw.githubusercontent.com/Be-Secure/BeSLab/main/$genesis_file_name
	   fi
  else
     bliman_setup_echo "yellow" "Genesis file already present. Skipping ..."
  fi
}

bliman_setup_update ()
{
    bliman_setup_echo "red" "TODO -- Coming Soon !!"
}


bliman_setup_remove ()
{
    bliman_setup_echo "red" "TODO -- Coming Soon !!"
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
    bliman_setup_echo "white" "and download the default beslab genesis file to the current      "
    bliman_setup_echo "white" "working directory.                                               "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "================================================================="
    bliman_setup_echo "white" "comands and usage"
    bliman_setup_echo "white" "================================================================="
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh install --version v0.4.0"
    bliman_setup_echo "white" "   [Install the BLIman and genesis file from Be-Secure community]    "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh remove"
    bliman_setup_echo "white" "   [Remove the BLIman installed] "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh update"
    bliman_setup_echo "white" "   [updates the BLIman to higher version if available.] "
    bliman_setup_echo "white" ""
    bliman_setup_echo "white" "./bliman_setup.sh update --force"
    bliman_setup_echo "white" "   [Updates the BLIman forcefully.]"

}
#### MAIN STARTS HERE
opts=()
args=()

while [[ -n "$1" ]]; do
  case "$1" in
        #--genesisPath | --force | --version)
	--force | --version)
           opts=("${opts[@]}" "$1")
	   ;; ## genesis file path on local system
        *)          
           args=("${args[@]}" "$1")
	   ;; ## command | genesis_path
  esac
  shift
done

[[ -z $command ]] && command="${args[0]}"
case $command in
     install)


       #([[ ${#opts[@]} -lt 1 ]] && bliman_setup_download && bliman_get_genesis_file && bliman_setup_install ) ||
       #([[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--genesisPath" ]] && __bliman_download && __bliman_get_genesis_file "${args[1]}" && __bliman_install) ||
       ([[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--version" ]] && bliman_setup_download "${args[1]}" && bliman_get_genesis_file "${args[1]}" && bliman_setup_install "${opts[0]}" "${args[1]}")
       #([[ ${#opts[@]} -eq 2 ]] && [[ "${opts[0]}" == "--version" ]] && __bliman_download "${args[1]}" && __bliman_get_genesis_file "${args[2]}" && __bliman_install "${opts[0]}" "${args[1]}") ||
       #([[ ${#opts[@]} -eq 2 ]] && [[ "${opts[0]}" == "--genesisPath" ]] && __bliman_download "${args[2]}" && __bliman_get_genesis_file "${args[1]}" && __bliman_install "${opts[1]}" "${args[2]}") ||
       #( echo ""; echo "Not a valid command."; bliman_setup_help)
       ;;
     remove)
       ([[ ${#opts[@]} -lt 1 ]] &&  bliman_setup_remove) ||
       ( echo ""; echo "Not a valid command."; bliman_setup_help)
       ;;
     update)
       ([[ ${#opts[@]} -lt 1 ]] &&  bliman_setup_update) ||
       ([[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--force" ]] && bliman_setup_update "${opts[0]}") ||
       ( echo ""; echo "Not a valid command."; bliman_setup_help) 
       ;;
     *)
        echo -e "Not a valid bliman setup command\n"
	bliman_setup_help
        exit 1
        ;;
esac
