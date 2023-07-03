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

function __bliman_update_service_availability() {
	local healthcheck_status=$(__bliman_determine_healthcheck_status)
	__bliman_set_availability "$healthcheck_status"
}

function __bliman_determine_healthcheck_status() {
	if [[ "$BLIMAN_OFFLINE_MODE" == "true" || "$COMMAND" == "offline" && "$QUALIFIER" == "enable" ]]; then
		echo ""
	else
		echo "$(__bliman_secure_curl_with_timeouts "${BLIMAN_CANDIDATES_REPO}/healthcheck")"
	fi
}

function __bliman_set_availability() {
	local healthcheck_status="$1"
	local detect_html="$(echo "$healthcheck_status" | tr '[:upper:]' '[:lower:]' | grep 'html')"
	if [[ -z "$healthcheck_status" ]]; then
		BLIMAN_AVAILABLE="false"
		__bliman_display_offline_warning "$healthcheck_status"
	elif [[ -n "$detect_html" ]]; then
		BLIMAN_AVAILABLE="false"
		__bliman_display_proxy_warning
	else
		BLIMAN_AVAILABLE="true"
	fi
}

function __bliman_display_offline_warning() {
	local healthcheck_status="$1"
	if [[ -z "$healthcheck_status" && "$COMMAND" != "offline" && "$BLIMAN_OFFLINE_MODE" != "true" ]]; then
		__bliman_echo_red "==== INTERNET NOT REACHABLE! ==================================================="
		__bliman_echo_red ""
		__bliman_echo_red " Some functionality is disabled or only partially available."
		__bliman_echo_red " If this persists, please enable the offline mode:"
		__bliman_echo_red ""
		__bliman_echo_red "   $ bli offline"
		__bliman_echo_red ""
		__bliman_echo_red "================================================================================"
		echo ""
	fi
}

function __bliman_display_proxy_warning() {
	__bliman_echo_red "==== PROXY DETECTED! ==========================================================="
	__bliman_echo_red "Please ensure you have open internet access to continue."
	__bliman_echo_red "================================================================================"
	echo ""
}
