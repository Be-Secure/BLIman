#!/bin/bash

function __bliman_launch_bes_lab_host_mode()
{
    oah install -v oah-bes-vm
    [[ "$?" -eq 1 ]] && __besman_echo_red "Failed" && return 1
}

function __bliman_launch_bes_lab_bare_metal_mode()
{
    echo "Launching beslab in bare metal mode"
    oah install -s oah-bes-vm
    [[ "$?" -eq 1 ]] && __besman_echo_red "Failed" && return 1

}