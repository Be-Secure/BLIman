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

function __bli_selfupdate() {
	local force_selfupdate
	local bliman_script_version_api
	local bliman_native_version_api

	if [[ "$BLIMAN_AVAILABLE" == "false" ]]; then
		echo "This command is not available while offline."
		return 1
	fi

	if [[ "$bliman_beta_channel" == "true" ]]; then
		bliman_script_version_api="${BLIMAN_CANDIDATES_REPO}/broker/version/bliman/script/beta"
		bliman_native_version_api="${BLIMAN_CANDIDATES_REPO}/broker/version/bliman/native/beta"
	else
		bliman_script_version_api="${BLIMAN_CANDIDATES_REPO}/broker/version/bliman/script/stable"
		bliman_native_version_api="${BLIMAN_CANDIDATES_REPO}/broker/version/bliman/native/stable"
	fi

	bliman_remote_script_version=$(__bliman_secure_curl "$bliman_script_version_api")
	bliman_remote_native_version=$(__bliman_secure_curl "$bliman_native_version_api")

	bliman_local_script_version=$(< "$BLIMAN_DIR/var/version")
	bliman_local_native_version=$(< "$BLIMAN_DIR/var/version_native")

	__bliman_echo_debug "Script: local version: $bliman_local_script_version; remote version: $bliman_remote_script_version"
	__bliman_echo_debug "Native: local version: $bliman_local_native_version; remote version: $bliman_remote_native_version"

	force_selfupdate="$1"
	export bliman_debug_mode
	if [[ "$bliman_local_script_version" == "$bliman_remote_script_version" && "$bliman_local_native_version" == "$bliman_remote_native_version" && "$force_selfupdate" != "force" ]]; then
		echo "No update available at this time."
	elif [[ "$bliman_beta_channel" == "true" ]]; then
		__bliman_secure_curl "${BLIMAN_CANDIDATES_REPO}/selfupdate/beta/${BLIMAN_PLATFORM}" | bash
	else
		__bliman_secure_curl "${BLIMAN_CANDIDATES_REPO}/selfupdate/stable/${BLIMAN_PLATFORM}" | bash
	fi
}
