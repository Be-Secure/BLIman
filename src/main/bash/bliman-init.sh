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
if [[ -z "$BLIMAN_NAMESPACE" ]]; then

	BLIMAN_NAMESPACE="asa1997"
	export BLIMAN_NAMESPACE
fi
if [ -z "$BLIMAN_CANDIDATES_REPO" ]; then
	export BLIMAN_CANDIDATES_REPO="https://raw.githubusercontent.com/$BLIMAN_NAMESPACE/BLIman/main"
fi

if [ -z "$BLIMAN_DIR" ]; then
	export BLIMAN_DIR="$HOME/.bliman"
fi

export BLIMAN_HOSTED_URL="https://raw.githubusercontent.com"
export BLIMAN_NAMESPACE="asa1997"
export BLIMAN_REPO_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BLIman/main"
export BLIMAN_LAB_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BeSLab/main"

if [[ -z "$BLIMAN_LAB_URL" ]]; then
	export BLIMAN_LAB_URL="$BLIMAN_HOSTED_URL/$BLIMAN_NAMESPACE/BeSLab/main"
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
		echo "LinuxX32"
		;;
	  x86_64)
		echo "LinuxX64"
		;;
	  armv6l)
		echo "LinuxARM32HF"
		;;
	  armv7l)
		echo "LinuxARM32HF"
		;;
	  armv8l)
		echo "LinuxARM32HF"
		;;
	  aarch64)
		echo "LinuxARM64"
		;;
	  *)
	  	echo "Exotic"
	  	;;
	  esac
	  ;;
	Darwin)
	  case $machine in
	  x86_64)
		echo "DarwinX64"
		;;
	  arm64)
		if [[ "$bliman_rosetta2_compatible" == 'true' ]]; then
			echo "DarwinX64"
		else
			echo "DarwinARM64"
		fi
		;;
	  *)
	  	echo "DarwinX64"
	  	;;
	  esac
	  ;;
	*)
	  echo "$kernel"
	esac
}

BLIMAN_PLATFORM="$(infer_platform | tr '[:upper:]' '[:lower:]')"
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

# Source bliman module scripts and extension files.
#
# Extension files are prefixed with 'bliman-' and found in the ext/ folder.
# Use this if extensions are written with the functional approach and want
# to use functions in the main bliman script. For more details, refer to
# <https://github.com/bliman/bliman-extensions>.
OLD_IFS="$IFS"
IFS=$'\n'
scripts=($(find "${BLIMAN_DIR}/src" "${BLIMAN_DIR}/ext" -type f -name 'bliman-*.sh'))
for f in "${scripts[@]}"; do
	source "$f"
done
IFS="$OLD_IFS"
unset OLD_IFS scripts f

# Create upgrade delay file if it doesn't exist
if [[ ! -f "${BLIMAN_DIR}/var/delay_upgrade" ]]; then
	touch "${BLIMAN_DIR}/var/delay_upgrade"
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
__bliman_echo_debug "Setting candidates csv: $BLIMAN_CANDIDATES_CSV"
if [[ "$zsh_shell" == 'true' ]]; then
	BLIMAN_CANDIDATES=(${(s:,:)BLIMAN_CANDIDATES_CSV})
else
	IFS=',' read -a BLIMAN_CANDIDATES <<< "${BLIMAN_CANDIDATES_CSV}"
fi

export BLIMAN_CANDIDATES_DIR="${BLIMAN_DIR}/candidates"

for candidate_name in "${BLIMAN_CANDIDATES[@]}"; do
	candidate_dir="${BLIMAN_CANDIDATES_DIR}/${candidate_name}/current"
	if [[ -h "$candidate_dir" || -d "${candidate_dir}" ]]; then
		__bliman_export_candidate_home "$candidate_name" "$candidate_dir"
		__bliman_prepend_candidate_to_path "$candidate_dir"
	fi
done
unset candidate_name candidate_dir
export PATH

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
		__bliman_echo_debug "ZSH completion script loaded..."
	elif [[ "$bash_shell" == 'true' ]]; then
		source "${BLIMAN_DIR}/contrib/completion/bash/bli"
		__bliman_echo_debug "Bash completion script loaded..."
	else
		__bliman_echo_debug "No completion scripts found for $SHELL"
	fi
fi

if [[ "$bliman_auto_env" == "true" ]]; then
	if [[ "$zsh_shell" == "true" ]]; then
		function bliman_auto_env() {
			if [[ -n $BLIMAN_ENV ]] && [[ ! $PWD =~ ^$BLIMAN_ENV ]]; then
				bli env clear
			fi
			if [[ -f .blimanrc ]]; then
				bli env
			fi
		}

		chpwd_functions+=(bliman_auto_env)
	else
		function bliman_auto_env() {
			if [[ -n $BLIMAN_ENV ]] && [[ ! $PWD =~ ^$BLIMAN_ENV ]]; then
				bli env clear
			fi
			if [[ "$BLIMAN_OLD_PWD" != "$PWD" ]] && [[ -f ".blimanrc" ]]; then
				bli env
			fi

			export BLIMAN_OLD_PWD="$PWD"
		}
		
		trimmed_prompt_command="${PROMPT_COMMAND%"${PROMPT_COMMAND##*[![:space:]]}"}"
		[[ -z "$trimmed_prompt_command" ]] && PROMPT_COMMAND="bliman_auto_env" || PROMPT_COMMAND="${trimmed_prompt_command%\;};bliman_auto_env"
	fi

	bliman_auto_env
fi
