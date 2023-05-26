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

function __bli_flush() {
	local qualifier="$1"

	case "$qualifier" in
	version)
		if [[ -f "${BLIMAN_DIR}/var/version" ]]; then
			rm -f "${BLIMAN_DIR}/var/version"
			__bliman_echo_green "Version file has been flushed."
		fi
		;;
	temp)
		__bliman_cleanup_folder "tmp"
		;;
	tmp)
		__bliman_cleanup_folder "tmp"
		;;
	metadata)
    	__bliman_cleanup_folder "var/metadata"
    	;;
	*)
		__bliman_cleanup_folder "tmp"
		__bliman_cleanup_folder "var/metadata"
		;;
	esac
}

function __bliman_cleanup_folder() {
	local folder="$1"
	local bliman_cleanup_dir
	local bliman_cleanup_disk_usage
	local bliman_cleanup_count

	bliman_cleanup_dir="${BLIMAN_DIR}/${folder}"
	bliman_cleanup_disk_usage=$(du -sh "$bliman_cleanup_dir")
	bliman_cleanup_count=$(ls -1 "$bliman_cleanup_dir" | wc -l)

	rm -rf "$bliman_cleanup_dir"
	mkdir "$bliman_cleanup_dir"

	__bliman_echo_green "${bliman_cleanup_count} archive(s) flushed, freeing ${bliman_cleanup_disk_usage}."
}
