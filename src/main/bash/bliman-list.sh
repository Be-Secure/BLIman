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

function __bli_list() {
	local candidate="$1"

	if [[ -z "$candidate" ]]; then
		__bliman_list_candidates
	else
		__bliman_list_versions "$candidate"
	fi
}

function __bliman_list_candidates() {
	if [[ "$BLIMAN_AVAILABLE" == "false" ]]; then
		__bliman_echo_red "This command is not available while offline."
	else
		__bliman_echo_paged "$(__bliman_secure_curl "${BLIMAN_CANDIDATES_API}/candidates/list")"
	fi
}

function __bliman_list_versions() {
	local candidate versions_csv

	candidate="$1"
	versions_csv="$(__bliman_build_version_csv "$candidate")"
	__bliman_determine_current_version "$candidate"

	if [[ "$BLIMAN_AVAILABLE" == "false" ]]; then
		__bliman_offline_list "$candidate" "$versions_csv"
	else
		__bliman_echo_paged "$(__bliman_secure_curl "${BLIMAN_CANDIDATES_API}/candidates/${candidate}/${BLIMAN_PLATFORM}/versions/list?current=${CURRENT}&installed=${versions_csv}")"
	fi
}

function __bliman_build_version_csv() {
	local candidate versions_csv

	candidate="$1"
	versions_csv=""

	if [[ -d "${BLIMAN_CANDIDATES_DIR}/${candidate}" ]]; then
		for version in $(find "${BLIMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 \( -type l -o -type d \) -exec basename '{}' \; | sort -r); do
			if [[ "$version" != 'current' ]]; then
				versions_csv="${version},${versions_csv}"
			fi
		done
		versions_csv=${versions_csv%?}
	fi
	echo "$versions_csv"
}

function __bliman_offline_list() {
	local candidate versions_csv

	candidate="$1"
	versions_csv="$2"

	__bliman_echo_no_colour "--------------------------------------------------------------------------------"
	__bliman_echo_yellow "Offline: only showing installed ${candidate} versions"
	__bliman_echo_no_colour "--------------------------------------------------------------------------------"

	local versions=($(echo ${versions_csv//,/ }))
	for ((i = ${#versions} - 1; i >= 0; i--)); do
		if [[ -n "${versions[${i}]}" ]]; then
			if [[ "${versions[${i}]}" == "$CURRENT" ]]; then
				__bliman_echo_no_colour " > ${versions[${i}]}"
			else
				__bliman_echo_no_colour " * ${versions[${i}]}"
			fi
		fi
	done

	if [[ -z "${versions[@]}" ]]; then
		__bliman_echo_yellow "   None installed!"
	fi

	__bliman_echo_no_colour "--------------------------------------------------------------------------------"
	__bliman_echo_no_colour "* - installed                                                                   "
	__bliman_echo_no_colour "> - currently in use                                                            "
	__bliman_echo_no_colour "--------------------------------------------------------------------------------"
}
