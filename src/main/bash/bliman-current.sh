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

function __bli_current() {
	local candidate="$1"

	echo ""
	if [ -n "$candidate" ]; then
		__bliman_determine_current_version "$candidate"
		if [ -n "$CURRENT" ]; then
			__bliman_echo_no_colour "Using ${candidate} version ${CURRENT}"
		else
			__bliman_echo_red "Not using any version of ${candidate}"
		fi
	else
		local installed_count=0
		for ((i = 0; i <= ${#BLIMAN_CANDIDATES[*]}; i++)); do
			# Eliminate empty entries due to incompatibility
			if [[ -n ${BLIMAN_CANDIDATES[${i}]} ]]; then
				__bliman_determine_current_version "${BLIMAN_CANDIDATES[${i}]}"
				if [ -n "$CURRENT" ]; then
					if [ ${installed_count} -eq 0 ]; then
						__bliman_echo_no_colour 'Using:'
						echo ""
					fi
					__bliman_echo_no_colour "${BLIMAN_CANDIDATES[${i}]}: ${CURRENT}"
					((installed_count += 1))
				fi
			fi
		done

		if [ ${installed_count} -eq 0 ]; then
			__bliman_echo_no_colour 'No candidates are in use'
		fi
	fi
}

function __bliman_determine_current_version() {
	local candidate present

	candidate="$1"
	present=$(__bliman_path_contains "${BLIMAN_CANDIDATES_DIR}/${candidate}")
	if [[ "$present" == 'true' ]]; then
		if [[ $PATH =~ ${BLIMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin ]]; then
			if [[ "$zsh_shell" == "true" ]]; then
				CURRENT=${match[1]}
			else
				CURRENT=${BASH_REMATCH[1]}
			fi
		fi

		if [[ "$CURRENT" == "current" ]]; then
			CURRENT=$(readlink "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${BLIMAN_CANDIDATES_DIR}/${candidate}/!!g")
		fi
	else
		CURRENT=""
	fi
}
