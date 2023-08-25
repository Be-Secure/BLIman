#!/bin/bash
# install:- channel: stable; cliVersion: 5.18.1; cliNativeVersion: 0.2.9; api: https://api.bliman.io/2

set -e

track_last_command() {
    last_command=$current_command
    current_command=$BASH_COMMAND
}
trap track_last_command DEBUG

echo_failed_command() {
    local exit_code="$?"
	if [[ "$exit_code" != "0" ]]; then
		echo "'$last_command': command failed with exit code $exit_code."
	fi
}
trap echo_failed_command EXIT


# Global variables
export BLIMAN_HOSTED_URL="https://raw.githubusercontent.com"
export BLIMAN_NAMESPACE="Be-Secure"
export BLIMAN_REPO_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BLIman/main"
export BLIMAN_VERSION="0.1.0"
# export BLIMAN_NATIVE_VERSION="0.2.9"
# infer platform
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
	MSYS*|MINGW*)
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
	esac
}

BLIMAN_PLATFORM="$(infer_platform)"
export BLIMAN_PLATFORM

if [ -z "$BLIMAN_DIR" ]; then
    BLIMAN_DIR="$HOME/.bliman"
    BLIMAN_DIR_RAW="$HOME/.bliman"
else
    BLIMAN_DIR_RAW="$BLIMAN_DIR"
fi
export BLIMAN_DIR

# Local variables
bliman_src_folder="${BLIMAN_DIR}/src"
bliman_tmp_folder="${BLIMAN_DIR}/tmp"
bliman_ext_folder="${BLIMAN_DIR}/ext"
bliman_etc_folder="${BLIMAN_DIR}/etc"
bliman_var_folder="${BLIMAN_DIR}/var"
bliman_candidates_folder="${BLIMAN_DIR}/candidates"
bliman_config_file="${bliman_etc_folder}/config"
bliman_bash_profile="${HOME}/.bash_profile"
bliman_bashrc="${HOME}/.bashrc"
bliman_zshrc="${ZDOTDIR:-${HOME}}/.zshrc"

bliman_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR BLIMAN TO WORK!!!
export BLIMAN_DIR="$BLIMAN_DIR_RAW"
[[ -s "${BLIMAN_DIR_RAW}/bin/bliman-init.sh" ]] && source "${BLIMAN_DIR_RAW}/bin/bliman-init.sh"
EOF
)

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
solaris=false;
freebsd=false;
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

echo "Looking for a previous installation of BLIMAN..."
if [ -d "$BLIMAN_DIR" ]; then
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
	echo "    $ sdk selfupdate force"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

# echo "Looking for unzip..."
# if ! command -v unzip > /dev/null; then
# 	echo "Not found."
# 	echo "======================================================================================================"
# 	echo " Please install unzip on your system using your favourite package manager."
# 	echo ""
# 	echo " Restart after installing unzip."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 1
# fi

# echo "Looking for zip..."
# if ! command -v zip > /dev/null; then
# 	echo "Not found."
# 	echo "======================================================================================================"
# 	echo " Please install zip on your system using your favourite package manager."
# 	echo ""
# 	echo " Restart after installing zip."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 1
# fi

# echo "Looking for curl..."
# if ! command -v curl > /dev/null; then
# 	echo "Not found."
# 	echo ""
# 	echo "======================================================================================================"
# 	echo " Please install curl on your system using your favourite package manager."
# 	echo ""
# 	echo " Restart after installing curl."
# 	echo "======================================================================================================"
# 	echo ""
# 	exit 1
# fi

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

echo "Installing BLIMAN scripts..."


# Create directory structure

echo "Create distribution directories..."
mkdir -p "$bliman_tmp_folder"
mkdir -p "$bliman_ext_folder"
mkdir -p "$bliman_etc_folder"
mkdir -p "$bliman_var_folder"
mkdir -p "$bliman_candidates_folder"

echo "Getting available candidates..."
echo "from ${BLIMAN_REPO_URL}/candidates.txt"
BLIMAN_CANDIDATES_CSV=$(curl -s "${BLIMAN_REPO_URL}/candidates.txt")
echo "$BLIMAN_CANDIDATES_CSV" > "${BLIMAN_DIR}/var/candidates"

echo "Prime the config file..."
touch "$bliman_config_file"
echo "bliman_auto_answer=false" >> "$bliman_config_file"
if [ -z "$ZSH_VERSION" -a -z "$BASH_VERSION" ]; then
    echo "bliman_auto_complete=false" >> "$bliman_config_file"
else
    echo "bliman_auto_complete=true" >> "$bliman_config_file"
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
} >> "$bliman_config_file"


# script cli distribution
echo "Installing script cli archive..."
# fetch distribution
# bliman_zip_file="${bliman_tmp_folder}/bliman-${BLIMAN_VERSION}.zip"
# echo "* Downloading..."
# curl --fail --location --progress-bar "${BLIMAN_SERVICE}/broker/download/bliman/install/${BLIMAN_VERSION}/${BLIMAN_PLATFORM}" > "$bliman_zip_file"

# check integrity
# echo "* Checking archive integrity..."
# ARCHIVE_OK=$(unzip -qt "$bliman_zip_file" | grep 'No errors detected in compressed data')
# if [[ -z "$ARCHIVE_OK" ]]; then
# 	echo "Downloaded zip archive corrupt. Are you connected to the internet?"
# 	echo ""
# 	echo "If problems persist, please ask for help on our Slack:"
# 	echo "* easy sign up: https://slack.bliman.io/"
# 	echo "* report on channel: https://bliman.slack.com/app_redirect?channel=user-issues"
# 	exit
# fi

# extract archive
# echo "* Extracting archive..."
# if [[ "$cygwin" == 'true' ]]; then
# 	bliman_tmp_folder=$(cygpath -w "$bliman_tmp_folder")
# 	bliman_zip_file=$(cygpath -w "$bliman_zip_file")
# fi
# unzip -qo "$bliman_zip_file" -d "$bliman_tmp_folder"

# copy in place
echo "* Copying archive contents..."
cp -r "contrib/" "$BLIMAN_DIR"
cp -r "src/main/bash" "$bliman_src_folder"
mkdir -p "$BLIMAN_DIR/bin/"
mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/"
# rm -f "$bliman_src_folder"/*
# cp -rf "${bliman_tmp_folder}"/bliman-*/* "$BLIMAN_DIR"

# clean up
# echo "* Cleaning up..."
# rm -rf "$bliman_tmp_folder"/bliman-*
# rm -rf "$bliman_zip_file"

echo ""

# # native cli distribution
# if [[ "$BLIMAN_PLATFORM" != "exotic" ]]; then
# # fetch distribution
# bliman_zip_file="${bliman_tmp_folder}/bliman-native-${BLIMAN_NATIVE_VERSION}.zip"
# echo "* Downloading..."
# curl --fail --location --progress-bar "${BLIMAN_SERVICE}/broker/download/native/install/${BLIMAN_NATIVE_VERSION}/${BLIMAN_PLATFORM}" > "$bliman_zip_file"

# # check integrity
# echo "* Checking archive integrity..."
# ARCHIVE_OK=$(unzip -qt "$bliman_zip_file" | grep 'No errors detected in compressed data')
# if [[ -z "$ARCHIVE_OK" ]]; then
# 	echo "Downloaded zip archive corrupt. Are you connected to the internet?"
# 	echo ""
# 	echo "If problems persist, please ask for help on our Slack:"
# 	echo "* easy sign up: https://slack.bliman.io/"
# 	echo "* report on channel: https://bliman.slack.com/app_redirect?channel=user-issues"
# 	exit
# fi

# # extract archive
# echo "* Extracting archive..."
# if [[ "$cygwin" == 'true' ]]; then
# 	bliman_tmp_folder=$(cygpath -w "$bliman_tmp_folder")
# 	bliman_zip_file=$(cygpath -w "$bliman_zip_file")
# fi
# unzip -qo "$bliman_zip_file" -d "$bliman_tmp_folder"

# # copy in place
# echo "* Copying archive contents..."
# rm -f "$bliman_libexec_folder"/*
# cp -rf "${bliman_tmp_folder}"/bliman-*/* "$BLIMAN_DIR"

# # clean up
# echo "* Cleaning up..."
# rm -rf "$bliman_tmp_folder"/bliman-*
# rm -rf "$bliman_zip_file"

# echo ""
# fi

echo "Set version to $BLIMAN_VERSION ..."
echo "$BLIMAN_VERSION" > "${BLIMAN_DIR}/var/version"

echo "Set native version to $BLIMAN_NATIVE_VERSION ..."
echo "$BLIMAN_NATIVE_VERSION" > "${BLIMAN_DIR}/var/version_native"


if [[ $darwin == true ]]; then
  touch "$bliman_bash_profile"
  echo "Attempt update of login bash profile on OSX..."
  if [[ -z $(grep 'bliman-init.sh' "$bliman_bash_profile") ]]; then
    echo -e "\n$bliman_init_snippet" >> "$bliman_bash_profile"
    echo "Added bliman init snippet to $bliman_bash_profile"
  fi
else
  echo "Attempt update of interactive bash profile on regular UNIX..."
  touch "${bliman_bashrc}"
  if [[ -z $(grep 'bliman-init.sh' "$bliman_bashrc") ]]; then
      echo -e "\n$bliman_init_snippet" >> "$bliman_bashrc"
      echo "Added bliman init snippet to $bliman_bashrc"
  fi
fi

echo "Attempt update of zsh profile..."
touch "$bliman_zshrc"
if [[ -z $(grep 'bliman-init.sh' "$bliman_zshrc") ]]; then
    echo -e "\n$bliman_init_snippet" >> "$bliman_zshrc"
    echo "Updated existing ${bliman_zshrc}"
fi


echo -e "\n\n\nAll done!\n\n"

echo "You are subscribed to the STABLE channel."

echo ""
echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${BLIMAN_DIR}/bin/bliman-init.sh\""
echo ""
echo "Then issue the following command:"
echo ""
echo "    sdk help"
echo ""
echo "Enjoy!!!"