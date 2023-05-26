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

function __bli_help() {
	__bliman_echo_no_colour ""
	__bliman_echo_no_colour "Usage: bli <command> [candidate] [version]"
	__bliman_echo_no_colour "       bli offline <enable|disable>"
	__bliman_echo_no_colour ""
	__bliman_echo_no_colour "   commands:"
	__bliman_echo_no_colour "       install   or i    <candidate> [version] [local-path]"
	__bliman_echo_no_colour "       uninstall or rm   <candidate> <version>"
	__bliman_echo_no_colour "       list      or ls   [candidate]"
	__bliman_echo_no_colour "       use       or u    <candidate> <version>"
	__bliman_echo_no_colour "       config"
	__bliman_echo_no_colour "       default   or d    <candidate> [version]"
	__bliman_echo_no_colour "       home      or h    <candidate> <version>"
	__bliman_echo_no_colour "       env       or e    [init|install|clear]"
	__bliman_echo_no_colour "       current   or c    [candidate]"
	__bliman_echo_no_colour "       upgrade   or ug   [candidate]"
	__bliman_echo_no_colour "       version   or v"
	__bliman_echo_no_colour "       help"
	__bliman_echo_no_colour "       offline           [enable|disable]"

	if [[ "$bliman_selfupdate_feature" == "true" ]]; then
		__bliman_echo_no_colour "       selfupdate        [force]"
	fi

	__bliman_echo_no_colour "       update"
	__bliman_echo_no_colour "       flush             [tmp|metadata|version]"
	__bliman_echo_no_colour ""
	__bliman_echo_no_colour "   candidate  :  the BLI to install: groovy, scala, grails, gradle, kotlin, etc."
	__bliman_echo_no_colour "                 use list command for comprehensive list of candidates"
	__bliman_echo_no_colour "                 eg: \$ bli list"
	__bliman_echo_no_colour "   version    :  where optional, defaults to latest stable if not provided"
	__bliman_echo_no_colour "                 eg: \$ bli install groovy"
	__bliman_echo_no_colour "   local-path :  optional path to an existing local installation"
	__bliman_echo_no_colour "                 eg: \$ bli install groovy 2.4.13-local /opt/groovy-2.4.13"
	__bliman_echo_no_colour ""
}
