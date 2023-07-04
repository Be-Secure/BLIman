#!/bin/bash

function __bliman_check_oah_bes_vm_available()
{
    local tmp_file="/tmp/list.txt"
    oah list >> "$tmp_file"
    if ! grep -qw "oah-bes-vm" "$tmp_file"
    then
        __bliman_echo_red "oah-bes-vm is not listed under oah-shell"
        return 1
    fi

}

function __bliman_launch_bes_lab_host_mode()
{
    oah install -v oah-bes-vm
    [[ "$?" -eq 1 ]] && __besman_echo_red "Failed" && return 1
}

function __bliman_launch_bes_lab_bare_metal_mode()
{
    oah install -s oah-bes-vm
    [[ "$?" -eq 1 ]] && __besman_echo_red "Failed" && return 1

}