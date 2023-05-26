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

function __bli_config() {
	local -r editor=(${EDITOR:=vi})

	if ! command -v "${editor[@]}" > /dev/null; then
		__bliman_echo_red "No default editor configured."
		__bliman_echo_yellow "Please set the default editor with the EDITOR environment variable."

		return 1
	fi

	"${editor[@]}" "${BLIMAN_DIR}/etc/config"
}