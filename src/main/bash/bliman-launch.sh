#!/bin/bash

function __bliman_launch()
{
    __bliman_check_oah_available
    __bliman_check_oah_bes_vm_available || return 1
    __bliman_set_mode
    if [[ $BLIMAN_LAB_MODE == "host" ]]; then
        __bliman_check_vagrant_available || return 1
        __bliman_checl_vm_available || return 1
        __bliman_launch_bes_lab_host_mode || return 1
    else
        __bliman_launch_bes_lab_bare_metal_mode || return 1
    fi
}

function __bliman_checl_vm_available()
{
    if [[ -z "$(which virtualbox)" ]]; then
        sudo apt update
        sudo apt upgrade
        __bliman_echo_white "Installing virtualbox"
        wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
        sudo apt update
        sudo apt install virtualbox
        virtualbox --version
        [[ "$?" -eq 1 ]] && __bliman_echo_red "Virtual Box installation failed" && return 1     
    fi
}

function __bliman_check_vagrant_available()
{
    
    if [[ -z "$(which vagrant)" ]]; then
        sudo apt update
        sudo apt upgrade
        __bliman_echo_white "Installing vagrant"
        sudo apt install virtualbox-ext-pack
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install vagrant
        vagrant --version
        [[ "$?" -eq 1 ]] && __bliman_echo_red "Vagrant installation failed" && return 1     
        

    fi
}