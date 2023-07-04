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

function __bliman_check_candidate_present() {
	local candidate="$1"

	if [ -z "$candidate" ]; then
		echo ""
		__bliman_echo_red "No candidate provided."
		__bli_help
		return 1
	fi
}

function __bliman_check_version_present() {
	local version="$1"

	if [ -z "$version" ]; then
		echo ""
		__bliman_echo_red "No candidate version provided."
		__bli_help
		return 1
	fi
}

function __bliman_determine_version() {
	local candidate version folder

	candidate="$1"
	version="$2"
	folder="$3"

	if [[ "$BLIMAN_AVAILABLE" == "false" && -n "$version" && -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
		VERSION="$version"

	elif [[ "$BLIMAN_AVAILABLE" == "false" && -z "$version" && -L "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" ]]; then
		VERSION=$(readlink "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${BLIMAN_CANDIDATES_DIR}/${candidate}/!!g")

	elif [[ "$BLIMAN_AVAILABLE" == "false" && -n "$version" ]]; then
		__bliman_echo_red "Stop! ${candidate} ${version} is not available while offline."
		return 1

	elif [[ "$BLIMAN_AVAILABLE" == "false" && -z "$version" ]]; then
		__bliman_echo_red "This command is not available while offline."
		return 1

	else
		if [[ -z "$version" ]]; then
			version=$(__bliman_secure_curl "${BLIMAN_CANDIDATES_REPO}/candidates/default/${candidate}")
		fi

		local validation_url="${BLIMAN_CANDIDATES_REPO}/candidates/validate/${candidate}/${version}/${BLIMAN_PLATFORM}"
		VERSION_VALID=$(__bliman_secure_curl "$validation_url")
		__bliman_echo_debug "Validate $candidate $version for $BLIMAN_PLATFORM: $VERSION_VALID"
		__bliman_echo_debug "Validation URL: $validation_url"

		if [[ "$VERSION_VALID" == 'valid' || "$VERSION_VALID" == 'invalid' && -n "$folder" ]]; then
			VERSION="$version"

		elif [[ "$VERSION_VALID" == 'invalid' && -L "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
			VERSION="$version"

		elif [[ "$VERSION_VALID" == 'invalid' && -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
			VERSION="$version"

		else
			if [[ -z "$version" ]]; then
				version="\b"
			fi

			echo ""
			__bliman_echo_red "Stop! $candidate $version is not available. Possible causes:"
			__bliman_echo_red " * $version is an invalid version"
			__bliman_echo_red " * $candidate binaries are incompatible with your platform"
			__bliman_echo_red " * $candidate has not been released yet"
			echo ""
			__bliman_echo_yellow "Tip: see all available versions for your platform:"
			echo ""
			__bliman_echo_yellow "  $ bli list $candidate"
			return 1
		fi
	fi
}
