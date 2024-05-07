![BLIman](./BLIman-logo-horizontal.png)

BLIman is a command line interface tool for managing [BeSLab](https://github.com/Be-Secure/BeSLab). It can be used to bring up the lab in 3 different modes.

To set up, please look at the [getting started guide](./Getting_started.md).


# Install BLIman

1.Open your terminal.

2.Download the setup script `curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/main/bliman_setup.sh`.

\[Note:\] For release candidate version use `curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/develop/bliman_setup.sh`

3.Chmod the file `chmod +x bliman_setup.sh` 

4.Execute the setup file `./bliman_setup.sh install --version <bliman release version>`
  bliman release version : A released version of bliman e.g v0.4.1 or 0.4.1. The released version can be find [here] (https://github.com/Be-Secure/BLIman/releases). For release candidates use "dev" as release version.
  
5.Source the init.sh `source $HOME/.bliman/bin/bliman-init.sh`

# Install BeSLab in different modes

Edit the genesis.yaml loaded into current working directory before executing following steps.

- Load the genesis.yaml file `bli load`

Execute any one of the following depending upon mode to be installed.

## Host mode

In the mode, we are hosting the lab in a VM which is brought up using vagrant and virtual box.

`bli initmode host`

## Bare Metal mode

In this mode, we are installing all the tools for lab in the user's machine itself. It is done using ansible and ansible roles.

`bli initmode bare`

## Lite mode

In this mode, we are installing the tools using pure shell scripts using [BeSman](https://github.com/Be-Secure/BeSman).

`bli initmode lite`

- Source the besman init file `source $HOME/.besman/bin/besman-init.sh`

- launch the lab `bli launchlab`

# Other commands

- `bli help`
