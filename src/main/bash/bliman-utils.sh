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

function __bliman_echo_debug() {
	if [[ "$bliman_debug_mode" == 'true' ]]; then
		echo "$1"
	fi
}

function __bliman_secure_curl() {
	if [[ "${bliman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location "$1"
	else
		curl --silent --location "$1"
	fi
}

function __bliman_secure_curl_download() {
	local curl_params
	curl_params=('--progress-bar' '--location')

	if [[ "${bliman_debug_mode}" == 'true' ]]; then
		curl_params+=('--verbose')
	fi

	if [[ "${bliman_curl_continue}" == 'true' ]]; then
		curl_params+=('-C' '-')
	fi

	if [[ -n "${bliman_curl_retry_max_time}" ]]; then
		curl_params+=('--retry-max-time' "${bliman_curl_retry_max_time}")
	fi

	if [[ -n "${bliman_curl_retry}" ]]; then
		curl_params+=('--retry' "${bliman_curl_retry}")
	fi

	if [[ "${bliman_insecure_ssl}" == 'true' ]]; then
		curl_params+=('--insecure')
	fi

	curl "${curl_params[@]}" "${@}"
}

function __bliman_secure_curl_with_timeouts() {
	if [[ "${bliman_insecure_ssl}" == 'true' ]]; then
		curl --insecure --silent --location --connect-timeout ${bliman_curl_connect_timeout} --max-time ${bliman_curl_max_time} "$1"
	else
		curl --silent --location --connect-timeout ${bliman_curl_connect_timeout} --max-time ${bliman_curl_max_time} "$1"
	fi
}

function __bliman_echo_paged() {
	if [[ -n "$PAGER" ]]; then
		echo "$@" | eval "$PAGER"
	elif command -v less >& /dev/null; then
		echo "$@" | less
	else
		echo "$@"
	fi
}

function __bliman_echo() {
	if [[ "$bliman_colour_enable" == 'false' ]]; then
		echo -e "$2"
	else
		echo -e "\033[1;$1$2\033[0m"
	fi
}

function __bliman_echo_red() {
	__bliman_echo "31m" "$1"
}

function __bliman_echo_no_colour() {
	echo "$1"
}

function __bliman_echo_yellow() {
	__bliman_echo "33m" "$1"
}

function __besman_echo_white {
	__bliman_echo "1m" "$1"
}

function __bliman_echo_green() {
	__bliman_echo "32m" "$1"
}

function __bliman_echo_cyan() {
	__bliman_echo "36m" "$1"
}

function __bliman_echo_confirm() {
	if [[ "$bliman_colour_enable" == 'false' ]]; then
		echo -n "$1"
	else
		echo -e -n "\033[1;33m$1\033[0m"
	fi
}
