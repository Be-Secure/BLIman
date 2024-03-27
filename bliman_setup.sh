#!/bin/bash
# install:- channel: stable; cliVersion: 5.18.1; cliNativeVersion: 0.2.9; api: https://api.bliman.io/2

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

createlogfile () {
   logfile="$1/$2"

   [[ ! -f $logfile ]] && touch $logfile
}

bliman_log() {
   datetime=$(date)
   while IFS= read -r line; do
     echo "$datetime : $line" >> $BLIMAN_INSTALL_LOG_FILE
   done
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
function __bliman_download ()
{
    default_repo_url='https://github.com/'
    default_repo_namespace='Be-Secure'
    default_repo_name='BLIman'
    default_tmp_location="/tmp/$default_repo_name"
    
    bliversion="$1"

    # script cli distribution
    if [ ! -z  ${BLIMAN_BROWSER_URL} ] && [ ! -z ${BLIMAN_NAMESPACE} ];then
       echo "Installing BLIman from ${BLIMAN_BROWSER_URL}/${BLIMAN_NAMESPACE}/BLIman.git"
       git clone ${BLIMAN_BROWSER_URL}/${BLIMAN_NAMESPACE}/$default_repo_name.git $default_tmp_location | bliman_log

    elif  [ -z  ${BLIMAN_BROWSER_URL} ] && [ ! -z ${BLIMAN_NAMESPACE} ];then
       echo "Installing BLIman from $default_repo_url/${BLIMAN_NAMESPACE}/BLIman.git"
       git clone $default_repo_url/${BLIMAN_NAMESPACE}/$default_repo_name.git $default_tmp_location | bliman_log

    elif  [ ! -z  ${BLIMAN_BROWSER_URL} ] && [ -z ${BLIMAN_NAMESPACE} ];then
       echo "Installing BLIman from ${BLIMAN_BROWSER_URL}/$default_repo_namespace/BLIman.git"
       git clone ${BLIMAN_BROWSER_URL}/${BLIMAN_NAMESPACE}/$default_repo_namespace/$default_repo_name.git $default_tmp_location | bliman_log
    else
       echo "Installing BLIman from $default_repo_url/$default_repo_namespace/BLIman.git"
       git clone $default_repo_url/$default_repo_namespace/$default_repo_name.git $default_tmp_location | bliman_log
    fi

    if [ ! -d $default_tmp_location ];then
           echo ""
           echo ""
           echo "======================================================================================================"
           echo " Not able to clone the BLIman."
           echo ""
           echo " Exit."
           echo "======================================================================================================"
           echo ""
           exit 1
    fi

}

function __bliman_sanatiy_check ()
{
   
	echo "Looking for a previous installation of BLIMAN..."
	if [ -d "$BLIMAN_DIR/bin/" ]; then
		echo "BLIMAN found."
		echo ""
		echo "======================================================================================================"
		echo " You already have BLIMAN installed."
		echo " BLIMAN was found at:"
		echo ""
		echo "    ${BLIMAN_DIR}"
		echo ""
		echo " Please consider running the following if you need to upgrade."
		echo ""
		echo "    $ bli selfupdate force"
		echo ""
		echo "======================================================================================================"
		echo ""
		exit 0
	fi

	echo "Looking for curl..."
	if ! command -v curl > /dev/null; then
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
function __bliman_install() {

	local genesis_path force_flag
	
	trap track_last_command DEBUG
	trap echo_failed_command EXIT

        bli_version=$2

        if [ -z "$BLIMAN_DIR" ]; then
                export BLIMAN_DIR="$HOME/.bliman"
                export BLIMAN_DIR_RAW="$HOME/.bliman"
        else
                export BLIMAN_DIR_RAW="$BLIMAN_DIR"
        fi
         
	echo "BLIMAN DIRECTORY is set to : $BLIMAN_DIR"

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
        echo "Create distribution directories..."
        mkdir -p "$bliman_tmp_folder"
        mkdir -p "$bliman_ext_folder"
        mkdir -p "$bliman_etc_folder"
        mkdir -p "$bliman_var_folder"
        mkdir -p "$bliman_candidates_folder"
        mkdir -p "$bliman_log_folder"


        DATE=$(date +"%Y-%m-%d-%k-%M")
        logfilename=bliman-install-log-$DATE.log

        createlogfile $bliman_log_folder $logfilename
        export BLIMAN_INSTALL_LOG_FILE="$bliman_log_folder/$logfilename"

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

	# Sanity checks
        __bliman_sanatiy_check

        #__bliman_download "$bli_version"

        BLIMAN_CANDIDATES_CSV=$(cat "$default_tmp_location/candidates.txt")
        echo "$BLIMAN_CANDIDATES_CSV" >"${BLIMAN_DIR}/var/candidates"

	# copy in place
	cp -r "$default_tmp_location/contrib/" "$BLIMAN_DIR" | bliman_log
	cp -r "$default_tmp_location/src/main/bash" "$bliman_src_folder" | bliman_log
	mkdir -p "$BLIMAN_DIR/bin/" | bliman_log
	mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/" | bliman_log

        echo "Prime the config file..."
        touch "$bliman_config_file" | bliman_log
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
	echo "* Cleaning up..."
	rm -rf "$default_tmp_location" | bliman_log

	echo ""
	
	echo "Set version to $BLIMAN_VERSION ..."
	echo "$BLIMAN_VERSION" >"${BLIMAN_DIR}/var/version"

	echo "Set native version to $BLIMAN_NATIVE_VERSION ..."
	echo "$BLIMAN_NATIVE_VERSION" >"${BLIMAN_DIR}/var/version_native"

	if [[ $darwin == true ]]; then
		touch "$bliman_bash_profile" | bliman_log
		echo "Attempt update of login bash profile on OSX..."
		if [[ -z $(grep 'bliman-init.sh' "$bliman_bash_profile") ]]; then
			echo -e "\n$bliman_init_snippet" >>"$bliman_bash_profile"
			echo "Added bliman init snippet to $bliman_bash_profile"
		fi
	else
		echo "Attempt update of interactive bash profile on regular UNIX..."
		touch "${bliman_bashrc}" | bliman_log
		if [[ -z $(grep 'bliman-init.sh' "$bliman_bashrc") ]]; then
			echo -e "\n$bliman_init_snippet" >>"$bliman_bashrc"
			echo "Added bliman init snippet to $bliman_bashrc"
		fi
	fi

	echo "Attempt update of zsh profile..."
	touch "$bliman_zshrc" | bliman_log
	if [[ -z $(grep 'bliman-init.sh' "$bliman_zshrc") ]]; then
		echo -e "\n$bliman_init_snippet" >>"$bliman_zshrc"
		echo "Updated existing ${bliman_zshrc}"
	fi

	if [ -f  $BLIMAN_DIR/bin/bliman-init.sh ];then
	   #source $BLIMAN_DIR/bin/bliman-init.sh
	   echo -e "\n\n\nAll done!\n\n"

           echo "Issue the following command to verify installation:"
           echo ""
           echo "    bli help"
           echo ""
            
	   bash -l
	else
	   echo ""
	   echo "BLIman not able to install properly."
	   echo ""
	   echo "   Please refer log file at $BLIMAN_INSTALL_LOG_FILE"
	fi

}

function __bliman_get_genesis_file ()
{
  local genesis_path genesis_file_name genesis_file_url present_working_dir
  genesis_file_name="beslab_genesis.yaml"
  genesis_path=$1
  genesis_file_url="$genesis_path/$genesis_file_name"

  if [[ -z $genesis_path ]];then
           echo -e "Genesis file path not provided."
           present_working_dir=`pwd`
           export BLIMAN_GENSIS_FILE_PATH="$present_working_dir/$genesis_file_name" 
	   echo -e "Downloading default genesis file from Be-Secure community."
	   curl -o $genesis_file_name https://github.com/Be-Secure/BeSLab/$genesis_file_name | bliman_log
  else
           echo -e "Genesis file path provided is $genesis_path."
	   export BLIMAN_GENSIS_FILE_PATH="$genesis_path"
           cp $BLIMAN_GENSIS_FILE_PATH . | bliman_log
  fi
}

__bliman_setup_update ()
{
    echo "TODO"
}


__bliman_setup_remove ()
{
    echo "TODO"
}

__bliman_setup_help ()
{
    echo ""
    echo "================================================================="
    echo ""
    echo "BLIman is the command line utiltiy to install the BeSLab.        "
    echo ""
    echo "================================================================="
    echo ""
    echo "bliman_setup is utility to install/ update / remove the BLIman   "
    echo "and loads the default beslab genesis file to the current         "
    echo "directory if no path is provided in install command.             "
    echo ""
    echo "================================================================="
    echo "comands and usage"
    echo "================================================================="
    echo ""
    echo "./bliman_setup.sh install"
    echo " [Install the BLIman with default beslab_genesis file from Be-Se "
    echo "   cure community.]                                                "
    echo ""
    echo "./bliman_setup.sh install --genesisPath < Path of genesis file >   "
    echo " [install the BLIman and uses the genesis file from the genesisPath]"
    echo ""
    echo "./bliman_setup.sh remove"
    echo " [Remove the BLIman installed] "
    echo ""
    echo "./bliman_setup.sh update"
    echo " [updates the BLIman to higher version if available.] "
    echo ""
    echo "./bliman_setup.sh update --force"
    echo " [Updates the BLIman forcefully.]"

}
#### MAIN STARTS HERE
opts=()
args=()

while [[ -n "$1" ]]; do
  case "$1" in
        --genesisPath | --force | --version)
	   	
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

       ([[ ${#opts[@]} -lt 1 ]] && __bliman_download && __bliman_get_genesis_file && __bliman_install ) ||
       ([[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--genesisPath" ]] __bliman_downlaod && __bliman_get_genesis_file "${args[1]}" && __bliman_install) ||
       ([[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--version" ]] && __bliman_download "${args[1]}" && __bliman_get_genesis_file && __bliman_install "${opts[0]}" "${args[1]}") ||
       ([[ ${#opts[@]} -eq 2 ]] && [[ "${opts[0]}" == "--version" ]] && __bliman_download "${args[1]}" && __bliman_get_genesis_file "${args[2]}" && __bliman_install "${opts[0]}" "${args[1]}") ||
       ([[ ${#opts[@]} -eq 2 ]] && [[ "${opts[0]}" == "--genesisPath" ]] && __bliman_download "${args[2]}" && __bliman_get_genesis_file "${args[1]}" && __bliman_install "${opts[1]}" "${args[2]}") ||
       ( echo ""; echo "Not a valid command."; __bliman_setup_help)
       ;;
     remove)
       ([[ ${#opts[@]} -lt 1 ]] &&  __bliman_setup_remove) ||
       ( echo ""; echo "Not a valid command."; __bliman_setup_help)
       ;;
     update)
       ([[ ${#opts[@]} -lt 1 ]] &&  __bliman_setup_update) ||
       ([[ ${#opts[@]} -eq 1 ]] && [[ "${opts[0]}" == "--force" ]] && __bliman_setup_update "${opts[0]}") ||
       ( echo ""; echo "Not a valid command."; __bliman_setup_help) 
       ;;
     *)
        echo -e "Not a valid bliman setup command\n"
	__bliman_setup_help
        exit 1
        ;;
esac
