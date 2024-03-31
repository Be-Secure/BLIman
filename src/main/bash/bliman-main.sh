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

function ___bliman_help() {
	if [[ -f "$BLIMAN_DIR/libexec/help" ]]; then
		"$BLIMAN_DIR/libexec/help"
	else
		__bli_help
	fi
}

function bli() {

	COMMAND="$1"
	QUALIFIER="$2"

	case "$COMMAND" in
	load)
		COMMAND="load-genesis"
		;;
	status)
		COMMAND="status"
		;;
	generate-vagrant)
		COMMAND="generate-vagrantfile"
		;;
	list)
		COMMAND="list"
		;;
	-V | --version)
		COMMAND="version"
		;;
	u)
		COMMAND="use"
		;;
	launchlab)
		COMMAND="launchlab"
		;;
	rm)
		COMMAND="uninstall"
		;;
	c)
		COMMAND="current"
		;;
	ug)
		COMMAND="upgrade"
		;;
	d)
		COMMAND="default"
		;;
	h)
		COMMAND="home"
		;;
	e)
		COMMAND="env"
		;;
	re)
		COMMAND="reload"
		;;
	help)
		if [ ! -z $2 ];then
                 case ${args[1]} in
                                        load)
                                                __bli_help_load
                                        ;;
                                        initmode)
                                                __bli_help_initmode
                                        ;;
                                        list)
                                                __bli_help_list
                                        ;;
                                        status)
                                                __bli_help_status
                                        ;;
                                        launchlab)
                                                __bli_help_launchlab
                                        ;;
                                        help)
                                                __bli_help
                                        ;;
		
	         esac
      	       else
                  __bli_help
	       fi
	       ;;
	esac

	#
	# Various sanity checks and default settings
	#

	export BLIMAN_COMMAND="$COMMAND"

	# Check candidates cache
	if [[ "$COMMAND" != "update" ]]; then
		___bliman_check_candidates_cache "$BLIMAN_CANDIDATES_CACHE" || return 1
	fi

	# Always presume internet availability
	BLIMAN_AVAILABLE="true"
	if [ -z "$BLIMAN_OFFLINE_MODE" ]; then
		BLIMAN_OFFLINE_MODE="false"
	fi

	# ...unless proven otherwise
	__bliman_update_service_availability

	# Load the bliman config if it exists.
	if [ -f "${BLIMAN_DIR}/etc/config" ]; then
		source "${BLIMAN_DIR}/etc/config"
	fi

	# no command provided
	if [[ -z "$COMMAND" ]]; then
		___bliman_help
		return 1
	fi

	# Check if it is a valid command
	CMD_FOUND=""
	if [[ "$COMMAND" != "selfupdate" || "$bliman_selfupdate_feature" == "true" ]]; then
		CMD_TARGET="${BLIMAN_DIR}/src/bliman-${COMMAND}.sh"
		if [[ -f "$CMD_TARGET" ]]; then
			CMD_FOUND="$CMD_TARGET"
		fi
	fi

	# Check if it is a sourced function
	CMD_TARGET="${BLIMAN_DIR}/ext/bliman-${COMMAND}.sh"
	if [[ -f "$CMD_TARGET" ]]; then
		CMD_FOUND="$CMD_TARGET"
	fi

	# couldn't find the command
	if [[ -z "$CMD_FOUND" ]]; then
		echo ""
		__bliman_echo_red "Invalid command: $COMMAND"
		echo ""
		___bliman_help
	fi

	# Validate offline qualifier
	if [[ "$COMMAND" == "offline" && -n "$QUALIFIER" && -z $(echo "enable disable" | grep -w "$QUALIFIER") ]]; then
		echo ""
		__bliman_echo_red "Stop! $QUALIFIER is not a valid offline mode."
	fi

	# Store the return code of the requested command
	local final_rc=0

	# Native commands found under libexec
	local native_command="${BLIMAN_DIR}/libexec/${COMMAND}"
	
	if [ -f "$native_command" ]; then
		"$native_command" "${@:2}"

	elif [ -n "$CMD_FOUND" ]; then

		# Check whether the candidate exists
		if [[ -n "$QUALIFIER" && "$COMMAND" != "help" && "$COMMAND" != "offline" && "$COMMAND" != "flush" && "$COMMAND" != "selfupdate" && "$COMMAND" != "env" && "$COMMAND" != "completion" && "$COMMAND" != "edit" && "$COMMAND" != "home" && -z $(echo "${BLIMAN_CANDIDATES[@]}" | grep -w "$QUALIFIER") ]]; then
			echo ""
			__bliman_echo_red "Stop! $QUALIFIER is not a valid candidate."
			return 1
		fi

		# Internal commands use underscores rather than hyphens
		local converted_command_name=$(echo "$COMMAND" | tr '-' '_')

		# Available as a shell function
		__bli_"$converted_command_name" "${@:2}"
	fi
	final_rc=$?
	return $final_rc
}
