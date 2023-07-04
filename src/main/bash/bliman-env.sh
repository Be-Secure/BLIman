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

function __bli_env() {
	local -r blimanrc=".blimanrc"
	local -r subcommand="$1"

	case $subcommand in
		"")    __bliman_load_env "$blimanrc" ;;
		init)  __bliman_create_env_file "$blimanrc";;
		install) __bliman_setup_env "$blimanrc";;
		clear) __bliman_clear_env "$blimanrc";;
	esac
}

function __bliman_setup_env() {
	local blimanrc="$1"

	if [[ ! -f "$blimanrc" ]]; then
		__bliman_echo_red "Could not find $blimanrc in the current directory."
		echo ""
		__bliman_echo_yellow "Run 'bli env init' to create it."

		return 1
	fi

	bliman_auto_answer="true" USE="n" __bliman_env_each_candidate "$blimanrc" "__bli_install"
	__bliman_load_env "$blimanrc"
}

function __bliman_load_env() {
	local blimanrc="$1"
	
	if [[ ! -f "$blimanrc" ]]; then
		__bliman_echo_red "Could not find $blimanrc in the current directory."
		echo ""
		__bliman_echo_yellow "Run 'bli env init' to create it."

		return 1
	fi

	__bliman_env_each_candidate "$blimanrc" "__bliman_check_and_use" && 
		BLIMAN_ENV=$PWD
}

function __bliman_check_and_use() {
	local -r candidate=$1
	local -r version=$2

	if [[ ! -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
		__bliman_echo_red "Stop! $candidate $version is not installed."
		echo ""
		__bliman_echo_yellow "Run 'bli env install' to install it."

		return 1
	fi

	__bli_use "$candidate" "$version"
}

function __bliman_create_env_file() {
	local blimanrc="$1"
	
	if [[ -f "$blimanrc" ]]; then
		__bliman_echo_red "$blimanrc already exists!"

		return 1
	fi

	__bliman_determine_current_version "java"

	local version
	[[ -n "$CURRENT" ]] && version="$CURRENT" || version="$(__bliman_secure_curl "${BLIMAN_CANDIDATES_REPO}/candidates/default/java")"

	cat <<-eof >|"$blimanrc"
	# Enable auto-env through the bliman_auto_env config
	# Add key=value pairs of BLIs to use below
	java=$version
	eof

	__bliman_echo_green "$blimanrc created."
}

function __bliman_clear_env() {
	local blimanrc="$1"

	if [[ -z $BLIMAN_ENV ]]; then
		__bliman_echo_red "No environment currently set!"
		return 1
	fi

	if [[ ! -f ${BLIMAN_ENV}/${blimanrc} ]]; then
		__bliman_echo_red "Could not find ${BLIMAN_ENV}/${blimanrc}."
		return 1
	fi

	__bliman_env_each_candidate "${BLIMAN_ENV}/${blimanrc}" "__bliman_env_restore_default_version"
	unset BLIMAN_ENV
}

function __bliman_env_restore_default_version() {
	local -r candidate="$1"

	local candidate_dir default_version
	candidate_dir="${BLIMAN_CANDIDATES_DIR}/${candidate}/current"
	if __bliman_is_symlink $candidate_dir; then
		default_version=$(basename $(readlink ${candidate_dir}))
		__bli_use "$candidate" "$default_version" >/dev/null &&
			__bliman_echo_yellow "Restored $candidate version to $default_version (default)"
	else
		__bliman_echo_yellow "No default version of $candidate was found"
	fi
}

function __bliman_env_each_candidate() {
	local -r filepath=$1
	local -r func=$2

	local normalised_line
	while IFS= read -r line || [[ -n "$line" ]]; do
		normalised_line="$(__bliman_normalise "$line")"

		__bliman_is_blank_line "$normalised_line" && continue

		if ! __bliman_matches_candidate_format "$normalised_line"; then
			__bliman_echo_red "Invalid candidate format!"
			echo ""
			__bliman_echo_yellow "Expected 'candidate=version' but found '$normalised_line'"

			return 1
		fi

		$func "${normalised_line%=*}" "${normalised_line#*=}" || return
	done < "$filepath"
}

function __bliman_is_symlink() {
	[[ -h "$1" ]]
}

function __bliman_is_blank_line() {
	[[ -z "$1" ]]
}

function __bliman_normalise() {
	local -r line_without_comments="${1/\#*/}"

	echo "${line_without_comments//[[:space:]]/}"
}

function __bliman_matches_candidate_format() {
	[[ "$1" =~ ^[[:lower:]]+\=.+$ ]]
}
