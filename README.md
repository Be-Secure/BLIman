![BLIman](./BLIman-logo-horizontal.png)

BLIman is a command line interface tool for managing [BeSLab](https://github.com/Be-Secure/BeSLab). It can be used to bring up the lab in 3 different modes.

To set up, please look at the [getting started guide](./Getting_started.md).

# Modes of BeSLab

## Host mode

In the mode, we are hosting the lab in a VM which is brought up using vagrant and virtual box.

`bli install host`

`bli launch`

## Bare Metal mode

In this mode, we are installing all the tools for lab in the user's machine itself. It is done using ansible and ansible roles.

`bli install bare`

`bli launch`

## Lite mode

In this mode, we are installing the tools using pure shell scripts using [BeSman](https://github.com/Be-Secure/BeSman).

`bli install lite`

`bli launch`

# Install BLIman

1.Open your terminal.

2.Clone the repo https://github.com/Be-Secure/BLIman.

3.Run the file https://github.com/Be-Secure/BLIman/blob/main/quick_install.sh - `./quick_install.sh` 

# Other commands

- `bli help`

- `bli list`
