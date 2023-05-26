#!/usr/bin/env bash

#
#   Copyright 2021 Marco Vermeulen
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

function ___bliman_check_candidates_cache() {
	local candidates_cache="$1"
	if [[ -f "$candidates_cache" && -z "$(< "$candidates_cache")" ]]; then
		__bliman_echo_red 'WARNING: Cache is corrupt. BLIMAN cannot be used until updated.'
		echo ''
		__bliman_echo_no_colour '  $ bli update'
		echo ''
		return 1
	else
		__bliman_echo_debug "Using existing cache: $BLIMAN_CANDIDATES_CSV"
		return 0
	fi
}
