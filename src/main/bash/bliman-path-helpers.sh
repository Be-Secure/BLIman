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

function __bliman_path_contains() {
	local candidate exists

	candidate="$1"
	exists="$(echo "$PATH" | grep "$candidate")"
	if [[ -n "$exists" ]]; then
		echo 'true'
	else
		echo 'false'
	fi
}

function __bliman_add_to_path() {
	local candidate present

	candidate="$1"

	present=$(__bliman_path_contains "$candidate")
	if [[ "$present" == 'false' ]]; then
		PATH="$BLIMAN_CANDIDATES_DIR/$candidate/current/bin:$PATH"
	fi
}

function __bliman_set_candidate_home() {
	local candidate version upper_candidate

	candidate="$1"
	version="$2"

	upper_candidate=$(echo "$candidate" | tr '[:lower:]' '[:upper:]')
	export "${upper_candidate}_HOME"="${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}"
}

function __bliman_export_candidate_home() {
	local candidate_name="$1"
	local candidate_dir="$2"
	local candidate_home_var="$(echo ${candidate_name} | tr '[:lower:]' '[:upper:]')_HOME"
	export $(echo "$candidate_home_var")="$candidate_dir"
}

function __bliman_determine_candidate_bin_dir() {
	local candidate_dir="$1"
	if [[ -d "${candidate_dir}/bin" ]]; then
		echo "${candidate_dir}/bin"
	else
		echo "$candidate_dir"
	fi
}

function __bliman_prepend_candidate_to_path() {
	local candidate_dir candidate_bin_dir

	candidate_dir="$1"
	candidate_bin_dir=$(__bliman_determine_candidate_bin_dir "$candidate_dir")
	echo "$PATH" | grep -q "$candidate_dir" || PATH="${candidate_bin_dir}:${PATH}"
	unset CANDIDATE_BIN_DIR
}

function __bliman_link_candidate_version() {
	local candidate version

	candidate="$1"
	version="$2"

	# Change the 'current' symlink for the candidate, hence affecting all shells.
	if [[ -L "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" ]]; then
		rm -rf "${BLIMAN_CANDIDATES_DIR}/${candidate}/current"
	fi

	ln -s "${version}" "${BLIMAN_CANDIDATES_DIR}/${candidate}/current"
}
