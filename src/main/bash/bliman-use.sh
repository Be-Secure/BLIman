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

function __bli_use() {
	local candidate version install

	candidate="$1"
	version="$2"
	__bliman_check_version_present "$version" || return 1
	__bliman_check_candidate_present "$candidate" || return 1

	if [[ ! -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
		echo ""
		__bliman_echo_red "Stop! Candidate version is not installed."
		echo ""
		__bliman_echo_yellow "Tip: Run the following to install this version"
		echo ""
		__bliman_echo_yellow "$ bli install ${candidate} ${version}"
		return 1
	fi

	# Just update the *_HOME and PATH for this shell.
	__bliman_set_candidate_home "$candidate" "$version"

	if [[ $PATH =~ ${BLIMAN_CANDIDATES_DIR}/${candidate}/([^/]+) ]]; then
		local matched_version

		if [[ "$zsh_shell" == "true" ]]; then
			matched_version=${match[1]}
		else
			matched_version=${BASH_REMATCH[1]}
		fi

		export PATH=${PATH//${BLIMAN_CANDIDATES_DIR}\/${candidate}\/${matched_version}/${BLIMAN_CANDIDATES_DIR}\/${candidate}\/${version}}
	fi

	if [[ ! (-L "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/current") ]]; then
		__bliman_echo_green "Setting ${candidate} version ${version} as default."
		__bliman_link_candidate_version "$candidate" "$version"
	fi

	echo ""
	__bliman_echo_green "Using ${candidate} version ${version} in this shell."
}
