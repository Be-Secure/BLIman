# BLIMAN

Before getting started, you should know what [BeSLab](https://github.com/Be-Secure/BeSLab) is.

## Installing BLIman

**For windows users**

1. Open your git bash
2. Run the below command to download the binaries
   
   `curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/main/bliman_setup.sh`
   `chmod +x bliman_setup.sh`
   `./bliman_setup.sh install --version <bliman release version>`
   `source $HOME/.bliman/bin/bliman-init.sh`
3. Edit the genesis.yaml file loaded to cureent working directory if required or use the default file.
4. Load the genesis.yaml file
   `bli load`

**For linux users**

1. Open your terminal
2. Run the below command to download the binaries

   `curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/main/bliman_setup.sh`
   `chmod +x bliman_setup.sh`
   `./bliman_setup.sh install --version <bliman release version>`
   `source $HOME/.bliman/bin/bliman-init.sh`
3. Edit the genesis.yaml file loaded to cureent working directory if required or use the default file.
4. Load the genesis.yaml file
   `bli load`

bliman release version: get the latest bliman release version [here] (https://github.com/Be-Secure/BLIman/releases)

## The 3 modes of BeSLab

BLIman helps you to set up and manage the BeSLab and it can bring BeSLab in 3 modes.

### 1. Host mode

If you wish to host your lab, and all of its tools, inside a guest vm, choose this mode. The os of the guest vm would be ubuntu as we are using ubuntu for all our projects and tools.

It is also useful for windows users as they wont have to worry about setting up another os in their machine.

All the tools inside the lab are installed by Ansible and ansible roles.

**Requirements**

To use this mode, you will have to install the following tools.

1. Git bash
2. Vagrant
3. Virtual Box

**Install lab in host mode**

1. Open your git bash
2. Make sure you have installed bliman by running, `bli help`

3. Run the below command.

   `bli initmode host`


### 2. Bare metal mode

If you already have an ubuntu os or wish to run the lab inside your machine itself, you can use this mode. 

It uses Ansible and ansible roles to install the tools required inside the lab.

You don't need to install a pre-requisites for this as it is done using BLIman itself.

**Install lab in bare-metal mode**

1. Open your terminal
2. Make sure you have installed bliman by running, `bli help`

3. Run the below command.

   `bli initmode bare`

### 3. Lightweight mode

As the name suggests this is a lightweight mode.

In this mode, the tools are installed using pure shell scripts.

You wont have to worry about pre-requisites. It will be installed by BLIman.

**Install lab in lightweight mode**

1. Open your terminal
2. Make sure you have installed bliman by running, `bli help`

3. Run the below command.

   `bli initmode lite`

## Install the lab

1. RUn the below command
   `source $HOME/.besman/bin/besman-init.sh`
   `bli launchlab`
