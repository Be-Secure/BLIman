![BLIman](./BLIman-logo-horizontal.png)

BLIman is a command line interface tool for managing [BeSLab](https://github.com/Be-Secure/BeSLab). It can be used to bring up the lab in 3 different modes.

To set up, please look at the [getting started guide](./Getting_started.md).


# Install BLIman

1.Open your terminal.

2.Download the setup script `curl -o bliman_setup.sh https://raw.githubusercontent.com/Be-Secure/BLIman/main/bliman_setup.sh`.

3. Chmod the file `chmod +x bliman_setup.sh` 

3.Execute the setup file `./bliman_setup.sh install`

# Modes of BeSLab

## Host mode

In the mode, we are hosting the lab in a VM which is brought up using vagrant and virtual box.

`bli load`

`bli initmode host`

`bli launchlab`

## Bare Metal mode

In this mode, we are installing all the tools for lab in the user's machine itself. It is done using ansible and ansible roles.

`bli load`

`bli initmode bare`

`bli launchlab`

## Lite mode

In this mode, we are installing the tools using pure shell scripts using [BeSman](https://github.com/Be-Secure/BeSman).

`bli load`

`bli initmode lite`

`bli launchlab`


# Other commands

- `bli help`

- `bli list`
