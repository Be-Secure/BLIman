#!/bin/bash


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
