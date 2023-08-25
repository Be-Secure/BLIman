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
__bliman_echo_no_colour 'Usage: bli <command> [mode]'
__bliman_echo_no_colour ''
__bliman_echo_no_colour 'Commands:'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'
__bliman_echo_no_colour ''
__bliman_echo_yellow 'help                                                            bli help'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'
__bliman_echo_no_colour 'Displays the help command.'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'
__bliman_echo_no_colour ''
__bliman_echo_yellow 'list                                                            bli list'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'
__bliman_echo_no_colour 'Displays the different modes'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'
__bliman_echo_no_colour ''
__bliman_echo_yellow 'install                                                         bli install <mode>'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'
__bliman_echo_no_colour 'Installs the pre-requisites for launching the lab in different modes.'
__bliman_echo_no_colour '----------------------------------------------------------------------------------------'

}
