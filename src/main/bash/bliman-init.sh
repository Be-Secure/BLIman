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

# set env vars if not set
# if [[ -z "$BLIMAN_NAMESPACE" ]]; then

# 	BLIMAN_NAMESPACE="Be-Secure"
# 	export BLIMAN_NAMESPACE
# fi
if [ ! -z $BLIMAN_DIR ];then
  LabConfigs="$BLIMAN_DIR/etc/genesis_data.sh"
else
  LabConfigs="$HOME/.bliman/etc/genesis_data.sh"
fi

[[ -f $LabConfigs ]] && source $LabConfigs

[[ -z  $BLIMAN_HOSTED_URL ]] && export BLIMAN_HOSTED_URL="https://raw.githubusercontent.com"
[[ -z  $BLIMAN_NAMESPACE ]] && export BLIMAN_NAMESPACE="Be-Secure"
[[ -z  $BLIMAN_REPO_URL ]] && export BLIMAN_REPO_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BLIman/main"
[[ -z  $BLIMAN_LAB_URL ]]  && export BLIMAN_LAB_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BeSLab/main"
[[ -z $BLIMAN_PLUGINS_REPO ]] && export BLIMAN_PLUGINS_REPO="http://github.com/$BLIMAN_NAMESPACE/BeSLab-Plugins/main"
[[ -z $BLIMAN_PLUGINS_DIR ]] && export BLIMAN_PLUGINS_DIR="$HOME/.beslab/plugins"
[[ -z $BLIMAN_PLUGINS_REPO_DIR ]] && export BLIMAN_PLUGINS_REPO_DIR="$HOME/BeSLab-Plugins"

if [ -z "$BLIMAN_CANDIDATES_REPO" ]; then
	if [ ! -z $BLIMAN_HOSTED_URL ] && [ ! -z $BLIMAN_NAMESPACE ];then
           export BLIMAN_CANDIDATES_REPO="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BLIman/main"
        elif [ -z $BLIMAN_HOSTED_URL ] && [ ! -z $BLIMAN_NAMESPACE ];then
           export BLIMAN_CANDIDATES_REPO="https://raw.githubusercontent.com/$BLIMAN_NAMESPACE/BLIman/main"
        elif [ ! -z $BLIMAN_HOSTED_URL ] && [ -z $BLIMAN_NAMESPACE ];then
           export BLIMAN_CANDIDATES_REPO="$BLIMAN_HOSTED_URL/Be-Secure/BLIman/main"
        else
           export BLIMAN_CANDIDATES_REPO="https://raw.githubusercontent.com/Be-Secure/BLIman/main"
        fi
fi

if [ -z "$BLIMAN_DIR" ]; then
	export BLIMAN_DIR="$HOME/.bliman"
fi

if [[ -z "$BLIMAN_LAB_URL" ]]; then
	if [ ! -z $BLIMAN_HOSTED_URL ] && [ ! -z $BLIMAN_NAMESPACE ];then
	   export BLIMAN_LAB_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BeSLab/main"
	elif [ -z $BLIMAN_HOSTED_URL ] && [ ! -z $BLIMAN_NAMESPACE ];then
           export BLIMAN_LAB_URL="https://raw.githubusercontent.com/$BLIMAN_NAMESPACE/BeSLab/main"
        elif [ ! -z $BLIMAN_HOSTED_URL ] && [ -z $BLIMAN_NAMESPACE ];then
	   export BLIMAN_LAB_URL="$BLIMAN_HOSTED_URL/Be-Secure/BeSLab/main"
	else
           export BLIMAN_LAB_URL="https://raw.githubusercontent.com/Be-Secure/BeSLab/main"
	fi
fi

# Load the bliman config if it exists.
if [ -f "${BLIMAN_DIR}/etc/config" ]; then
	source "${BLIMAN_DIR}/etc/config"
fi

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

BLIMAN_PLATFORM="$(infer_platform)"
export BLIMAN_PLATFORM

# OS specific support (must be 'true' or 'false').
cygwin=false
darwin=false
solaris=false
freebsd=false
BLIMAN_KERNEL="$(uname -s)"
case "${BLIMAN_KERNEL}" in
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
# Determine shell
zsh_shell=false
bash_shell=false

if [[ -n "$ZSH_VERSION" ]]; then
	zsh_shell=true
elif [[ -n "$BASH_VERSION" ]]; then
	bash_shell=true
fi

#source the utility file first.
source "${BLIMAN_DIR}/src/bliman-utils.sh"

# Source bliman module scripts and extension files.
#
# Extension files are prefixed with 'bliman-' and found in the ext/ folder.
# Use this if extensions are written with the functional approach and want
# to use functions in the main bliman script. For more details, refer to
# <https://github.com/bliman/bliman-extensions>.
OLD_IFS="$IFS"
IFS=$'\n'
scripts=($(find "${BLIMAN_DIR}/src" "${BLIMAN_DIR}/ext" -type f -name 'bliman-*.sh' ! -name 'bliman-utils.sh'))
for f in "${scripts[@]}"; do
	source "$f"
done
IFS="$OLD_IFS"
unset OLD_IFS scripts

__bliman_createlogfile

# Create upgrade delay file if it doesn't exist
if [[ ! -f "${BLIMAN_DIR}/var/delay_upgrade" ]]; then
	touch "${BLIMAN_DIR}/var/delay_upgrade" 2>&1 | __bliman_log
fi

# set curl connect-timeout and max-time
if [[ -z "$bliman_curl_connect_timeout" ]]; then bliman_curl_connect_timeout=7; fi
if [[ -z "$bliman_curl_max_time" ]]; then bliman_curl_max_time=10; fi

# set curl retry
if [[ -z "${bliman_curl_retry}" ]]; then bliman_curl_retry=0; fi

# set curl retry max time in seconds
if [[ -z "${bliman_curl_retry_max_time}" ]]; then bliman_curl_retry_max_time=60; fi

# set curl to continue downloading automatically
if [[ -z "${bliman_curl_continue}" ]]; then bliman_curl_continue=true; fi

# read list of candidates and set array
BLIMAN_CANDIDATES_CACHE="${BLIMAN_DIR}/var/candidates"
export BLIMAN_CANDIDATES_CACHE
BLIMAN_CANDIDATES_CSV=$(<"$BLIMAN_CANDIDATES_CACHE")
export BLIMAN_CANDIDATES_CSV
#__bliman_echo_debug "Setting candidates csv: $BLIMAN_CANDIDATES_CSV"
if [[ "$zsh_shell" == 'true' ]]; then
	BLIMAN_CANDIDATES=(${(s:,:)BLIMAN_CANDIDATES_CSV})
else
	IFS=',' read -a BLIMAN_CANDIDATES <<< "${BLIMAN_CANDIDATES_CSV}"
fi

export BLIMAN_CANDIDATES_DIR="${BLIMAN_DIR}/candidates"

for candidate_name in "${BLIMAN_CANDIDATES[@]}"; do
	candidate_dir="${BLIMAN_CANDIDATES_DIR}/${candidate_name}/current"
	if [[ -h "$candidate_dir" || -d "${candidate_dir}" ]]; then
                export BLIMAN_LAB_MODE=${candidate_name} 
		[[ -f "${BLIMAN_CANDIDATES_DIR}/${candidate_name}/current/version" ]] && export BLIMAN_LAB_VERSION=$(cat "${BLIMAN_CANDIDATES_DIR}/${candidate_name}/current/version")
		__bliman_export_candidate_home "$candidate_name" "$candidate_dir"
		__bliman_prepend_candidate_to_path "$candidate_dir"
	fi
done
unset candidate_name candidate_dir
export PATH=$PATH:${BLIMAN_DIR}/bin

# source completion scripts
if [[ "$bliman_auto_complete" == 'true' ]]; then
	if [[ "$zsh_shell" == 'true' ]]; then
		# initialize zsh completions (if not already done)
		if ! (( $+functions[compdef] )) ; then
			autoload -Uz compinit
			if [[ $ZSH_DISABLE_COMPFIX == 'true' ]]; then
				compinit -u -C
			else
				compinit
			fi
		fi
		autoload -U bashcompinit
		bashcompinit
		source "${BLIMAN_DIR}/contrib/completion/bash/bli"
		#__bliman_echo_debug "ZSH completion script loaded..."
	elif [[ "$bash_shell" == 'true' ]]; then
		source "${BLIMAN_DIR}/contrib/completion/bash/bli"
		#__bliman_echo_debug "Bash completion script loaded..."
	#else
		#__bliman_echo_debug "No completion scripts found for $SHELL"
	fi
fi

#if [[ "$bliman_auto_env" == "true" ]]; then
#	if [[ "$zsh_shell" == "true" ]]; then
#		function bliman_auto_env() {
#			if [[ -n $BLIMAN_ENV ]] && [[ ! $PWD =~ ^$BLIMAN_ENV ]]; then
#				bli env clear
#			fi
#			if [[ -f .blimanrc ]]; then
#				bli env
#			fi
#		}
#
#		chpwd_functions+=(bliman_auto_env)
#	else
#		function bliman_auto_env() {
#			if [[ -n $BLIMAN_ENV ]] && [[ ! $PWD =~ ^$BLIMAN_ENV ]]; then
#				bli env clear
#			fi
#			if [[ "$BLIMAN_OLD_PWD" != "$PWD" ]] && [[ -f ".blimanrc" ]]; then
#				bli env
#			fi
#
#			export BLIMAN_OLD_PWD="$PWD"
#		}
#		
#		trimmed_prompt_command="${PROMPT_COMMAND%"${PROMPT_COMMAND##*[![:space:]]}"}"
#		[[ -z "$trimmed_prompt_command" ]] && PROMPT_COMMAND="bliman_auto_env" || PROMPT_COMMAND="${trimmed_prompt_command%\;};bliman_auto_env"
#	fi
#
#	bliman_auto_env
#fi

[[ -f "$BLIMAN_DIR/tmp/source.sh" ]] && source "$BLIMAN_DIR/tmp/source.sh"

if [ -d "$HOME/.besman" ];then
      gitlab_user_data_file_path="$HOME/.besman/gitlabUserDetails"
elif [ -d "$HOME/.bliman" ];then
      gitlab_user_data_file_path="$HOME/.bliman/gitlabUserDetails"
fi

if [ -f $gitlab_user_data_file_path ];then
  GITUSER=`cat $gitlab_user_data_file_path | grep "GITLAB_USERNAME:" | awk '{print $2}'`
  GITUSERTOKEN=`cat $gitlab_user_data_file_path | grep "GITLAB_USERTOKEN:" | awk '{print $2}'`
fi

if [ -d "$HOME/.besman" ];then
   beslighthousedatafile="$HOME/.besman/beslighthousedata"
elif  [ -d "$HOME/.bliman" ];then
   beslighthousedatafile="$HOME/.bliman/beslighthousedata"
fi

if [ -f $beslighthousedatafile ];then
   
   beslighthousePath=`cat $beslighthousedatafile | grep "BESLIGHTHOUSE_DIR:" | awk '{print $2}'`
   beslighthouse_config_path=$beslighthousePath/src/apiDetailsConfig.json
   
   sed -i '/"activeTool"/c\"activeTool": "gitlab",' $beslighthouse_config_path 2>&1 | __bliman_log
   sed -i "/\"namespace\"/c\"namespace\": \"$GITUSER\"," $beslighthouse_config_path 2>&1 | __bliman_log
   sed -i "/\"token\"/c\"token\": \"$GITUSERTOKEN\"" $beslighthouse_config_path 2>&1 | __bliman_log
   
   labName=$( grep "\"labName\"" $beslighthouse_config_path | cut -d ":" -f2- | { read x; echo "${x//\"}"; })
   
   if [ ! -z $BESLAB_DOMAIN_NAME ];then
      domainURL="http://$BESLAB_DOMAIN_NAME"
   else
      myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
      domainURL="http://$myip"
   fi
   
   if [ ! -z $BESLAB_PROXY_API_URL ];then
     sed -i "/\"apiUrl\"/c\"apiUrl\": \"$BESLAB_PROXY_API_URL\"," $beslighthouse_config_path 2>&1 | __bliman_log
   else
     sed -i "/\"apiUrl\"/c\"apiUrl\": \"$domainURL:5000\"," $beslighthouse_config_path 2>&1 | __bliman_log
   fi 
   
   sed -i "/\"gitLabUrl\"/c\"gitLabUrl\": \"$domainURL\"," $beslighthouse_config_path 2>&1 | __bliman_log
   
   if [ ! -z $BESMAN_LAB_NAME ];then
      sed -i "/\"labName\"/c\"labName\": \"$BESMAN_LAB_NAME\"" $beslighthouse_config_path 2>&1 | __bliman_log
   else
      sed -i "/\"labName\"/c\"labName\": \"Be-Secure\"" $beslighthouse_config_path 2>&1 | __bliman_log
   fi

   sed -i "/\"version\"/c\"version\": \"$BESLAB_DASHBOARD_RELEASE_VERSION\"," $beslighthouse_config_path 2>&1 | __bliman_log

fi
