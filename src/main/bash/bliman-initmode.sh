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

function __bli_initmode() {
	local candidate version folder

	candidate="$1"
	version="$2"
	folder="$3"

	__bliman_echo_white ""
        __bliman_echo_yellow "##############################################################################"
        __bliman_echo_yellow "                       Setting lab mode as $candidate                         "
        __bliman_echo_yellow "##############################################################################"
        __bliman_echo_white ""

	__bliman_check_candidate_available "$candidate" || return 1
	__bliman_check_cadidate_installed "$candidate"
	#__bliman_determine_version "$candidate" "$version" "$folder" || return 1

	if [[ ! -z "${INSTALLED_CANDIDATE_VERSION}" ]] && [[ "${INSTALLED_CANDIDATE_VERSION}" == "$version" ]]; then
		echo ""
		__bliman_echo_yellow "${candidate} is already installed with the same version."
		echo ""
		return 0
	else
		__bliman_install_candidate_version "$candidate" "$version" || return 1
	fi

	#if [[ ${VERSION_VALID} == 'valid' ]]; then
	#	__bliman_determine_current_version "$candidate"
	#	__bliman_install_candidate_version "$candidate" "$VERSION" || return 1

	#	if [[ "$bliman_auto_answer" != 'true' && "$auto_answer_upgrade" != 'true' && -n "$CURRENT" ]]; then
	#		__bliman_echo_confirm "Do you want ${candidate} ${VERSION} to be set as default? (Y/n): "
	#		read USE
	#	fi

	#	if [[ -z "$USE" || "$USE" == "y" || "$USE" == "Y" ]]; then
	#		echo ""
	#		__bliman_echo_green "Setting ${candidate} ${VERSION} as default."
			# __bliman_link_candidate_version "$candidate" "$VERSION"
	#		__bliman_add_to_path "$candidate"
	#	fi

	#	return 0
	#elif [[ "$VERSION_VALID" == 'invalid' && -n "$folder" ]]; then
	#	__bliman_install_local_version "$candidate" "$VERSION" "$folder" || return 1
	#else
	#	echo ""
	#	__bliman_echo_red "Stop! $1 is not a valid ${candidate} version."
	#	return 1
	#fi
}

function __bliman_install_candidate_version() {
	local candidate version

	candidate="$1"
	version="$2"
	export BLIMAN_LAB_MODE="$candidate"

	mkdir -p "${BLIMAN_CANDIDATES_DIR}/${candidate}/current" | __bliman_log
        [[ ! -d "${BLIMAN_CANDIDATES_DIR}/active" ]] && mkdir ${BLIMAN_CANDIDATES_DIR}  
        if [ ! -f "${BLIMAN_CANDIDATES_DIR}/active/mode" ];then
	   touch "${BLIMAN_CANDIDATES_DIR}/active/mode" | __bliman_log
	fi
	echo "$candidate" > "${BLIMAN_CANDIDATES_DIR}/active/mode"
        
	__bliman_download "$candidate" "$version" || return 1
        touch "${BLIMAN_CANDIDATES_DIR}/${candidate}/current/version" | __bliman_log
	echo "$version" >> ${BLIMAN_CANDIDATES_DIR}/${candidate}/current/version

	__bliman_echo_green "Lab mode is set to $candidate"
	echo ""
	__bliman_echo_yellow "Execute \"bli launchlab\" to install beslab in $candidate mode."
	echo ""

	# rm -rf "${BLIMAN_DIR}/tmp/out"
	# unzip -oq "${BLIMAN_DIR}/tmp/${candidate}-${version}.zip" -d "${BLIMAN_DIR}/tmp/out"
	# mv -f "$BLIMAN_DIR"/tmp/out/* "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}"
	#__bliman_echo_green "Done installing!"
	#echo ""
}

function __bliman_install_local_version() {
	local candidate version folder version_length version_length_max

	version_length_max=15

	candidate="$1"
	version="$2"
	folder="$3"

	# Validate max length of version
	version_length=${#version}
	__bliman_echo_debug "Validating that actual version length ($version_length) does not exceed max ($version_length_max)"

	if [[ $version_length -gt $version_length_max ]]; then
		__bliman_echo_red "Invalid version! ${version} with length ${version_length} exceeds max of ${version_length_max}!"
		return 1
	fi

	mkdir -p "${BLIMAN_CANDIDATES_DIR}/${candidate}"

	# handle relative paths
	if [[ "$folder" != /* ]]; then
		folder="$(pwd)/$folder"
	fi

	if [[ -d "$folder" ]]; then
		__bliman_echo_green "Linking ${candidate} ${version} to ${folder}"
		ln -s "$folder" "${BLIMAN_CANDIDATES_DIR}/${candidate}/${version}" | __bliman_log
		__bliman_echo_green "Done installing!"
	else
		__bliman_echo_red "Invalid path! Refusing to link ${candidate} ${version} to ${folder}."
		return 1
	fi

	echo ""
}

function __bliman_download() {
	local candidate version

	candidate="$1"
	version="$2"

	metadata_folder="${BLIMAN_DIR}/var/metadata"
	mkdir -p ${metadata_folder} | __bliman_log
		
	local platform_parameter="$BLIMAN_PLATFORM"
	local download_url="${BLIMAN_CANDIDATES_REPO}/candidates/download/${candidate}/${platform_parameter}/installer.sh"
	# local base_name="${candidate}-${version}"
	# local tmp_headers_file="${BLIMAN_DIR}/tmp/${base_name}.headers.tmp"
	# local headers_file="${metadata_folder}/${base_name}.headers"

	# export local binary_input="${BLIMAN_DIR}/tmp/${base_name}.bin"
	# export local zip_output="${BLIMAN_DIR}/tmp/${base_name}.zip"

	# echo ""
	# __bliman_echo_no_colour "Downloading: ${candidate} ${version}"
	# echo ""
	# __bliman_echo_no_colour "In progress..."
	# echo ""

	# download binary
	__bliman_secure_curl "$download_url" | bash | __bliman_log
	# __bliman_secure_curl_download "${download_url}" --output "${binary_input}" --dump-header "${tmp_headers_file}"
	# grep '^X-Bliman' "${tmp_headers_file}" > "${headers_file}"
	# __bliman_echo_debug "Downloaded binary to: ${binary_input} (HTTP headers written to: ${headers_file})"

	# # post-installation hook: implements function __bliman_post_installation_hook
	# # responsible for taking `binary_input` and producing `zip_output`
	# local post_installation_hook="${BLIMAN_DIR}/tmp/hook_post_${candidate}_${version}.sh"
	# __bliman_echo_debug "Get post-installation hook: ${BLIMAN_CANDIDATES_REPO}/hooks/post/${candidate}/${version}/${platform_parameter}"
	# __bliman_secure_curl "${BLIMAN_CANDIDATES_REPO}/hooks/post/${candidate}/${version}/${platform_parameter}" >| "$post_installation_hook"
	# __bliman_echo_debug "Copy remote post-installation hook: ${post_installation_hook}"
	# source "$post_installation_hook"
	# __bliman_post_installation_hook || return 1
	# __bliman_echo_debug "Processed binary as: $zip_output"
	# __bliman_echo_debug "Completed post-installation hook..."
		
	# __bliman_validate_zip "${zip_output}" || return 1
	# __bliman_checksum_zip "${zip_output}" "${headers_file}" || return 1
	echo ""
}

function __bliman_validate_zip() {
	local zip_archive zip_ok

	zip_archive="$1"
	zip_ok=$(unzip -t "$zip_archive" | grep 'No errors detected in compressed data')
	if [ -z "$zip_ok" ]; then
		rm -f "$zip_archive" | __bliman_log
		echo ""
		__bliman_echo_red "Stop! The archive was corrupt and has been removed! Please try installing again."
		return 1
	fi
}

function __bliman_checksum_zip() {
	local -r zip_archive="$1"
	local -r headers_file="$2"
	local algorithm checksum cmd
	local shasum_avail=false
	local md5sum_avail=false
	
	if [ -z "${headers_file}" ]; then
		echo ""
		__bliman_echo_debug "Skipping checksum for cached artifact"
		return
	elif [ ! -f "${headers_file}" ]; then
		echo ""
		__bliman_echo_yellow "Metadata file not found at '${headers_file}', skipping checksum..."
		return
	fi
	
	if [[ "$bliman_checksum_enable" != "true" ]]; then
		echo ""
		__bliman_echo_yellow "Checksums are disabled, skipping verification..."
		return
	fi
	
	#Check for the appropriate checksum tools
	if command -v shasum > /dev/null 2>&1; then
		shasum_avail=true
	fi
	if command -v md5sum > /dev/null 2>&1; then
		md5sum_avail=true
	fi
	
	while IFS= read -r line; do
		algorithm=$(echo $line | sed -n 's/^X-Bliman-Checksum-\(.*\):.*$/\1/p' | tr '[:lower:]' '[:upper:]')
		checksum=$(echo $line | sed -n 's/^X-Bliman-Checksum-.*:\(.*\)$/\1/p' | tr -cd '[:alnum:]')
		
		if [[ -n ${algorithm} && -n ${checksum} ]]; then
			
			if [[ "$algorithm" =~ 'SHA' && "$shasum_avail" == 'true' ]]; then
				cmd="echo \"${checksum} *${zip_archive}\" | shasum --check --quiet"
				
			elif [[ "$algorithm" =~ 'MD5' && "$md5sum_avail" == 'true' ]]; then
				cmd="echo \"${checksum} ${zip_archive}\" | md5sum --check --quiet"
			fi
			
			if [[ -n $cmd ]]; then
				__bliman_echo_no_colour "Verifying artifact: ${zip_archive} (${algorithm}:${checksum})"

				if ! eval "$cmd"; then
					rm -f "$zip_archive" | __bliman_log
					echo ""
					__bliman_echo_red "Stop! An invalid checksum was detected and the archive removed! Please try re-installing."
					return 1
				fi
			else
				__bliman_echo_no_colour "Not able to perform checksum verification at this time."
			fi
		fi
  	done < ${headers_file}
}
