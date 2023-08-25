# BLIMAN! CLI
### The Software Development Kit Manager Command Line Interface

# BLIman CLI

BLIman CLI is a tool for managing [BeSLab](https://github.com/Be-Secure/BeSLab).

It can be used to bring up the lab in 3 different modes.

# Modes of BeSLab

## Host mode

In the mode, we are hosting the lab in a VM which is brought up using vagrant and virtual box.

`bli install host`

`bli launch`

## Bare Metal mode

In this mode, we are installing all the tools for lab in the user's machine itself. It is done using ansible and ansible roles.

`bli install bare`

`bli launch`

## Light mode

In this mode, we are installing the tools using pure shell scripts using [BeSman](https://github.com/Be-Secure/BeSman).

`bli install light`

`bli launch`

# Other commands

- `bli help`

- `bli list`