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

function __bli_home() {
	local candidate version

	candidate="$1"
	version="$2"
	__bliman_check_version_present "$version" || return 1
	__bliman_check_candidate_present "$candidate" || return 1
	__bliman_determine_version "$candidate" "$version" || return 1

	if [[ ! -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
		echo ""
		__bliman_echo_red "Stop! Candidate version is not installed."
		echo ""
		__bliman_echo_yellow "Tip: Run the following to install this version"
		echo ""
		__bliman_echo_yellow "$ bli install ${candidate} ${version}"
		return 1
	fi

	echo -n "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}"
}
