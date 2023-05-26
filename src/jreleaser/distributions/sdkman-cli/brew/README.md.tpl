# BLIMAN! Homebrew Tap

A Homebrew tap containing the Formula for the BLIMAN! CLI.

## Installation

```sh
$ brew tap bliman/tap
$ brew install bliman-cli
```

After successful installation add the following lines to the end of your `.bash_profile`

```sh
export BLIMAN_DIR=$(brew --prefix bliman-cli)/libexec
[[ -s "${BLIMAN_DIR}/bin/bliman-init.sh" ]] && source "${BLIMAN_DIR}/bin/bliman-init.sh"
```

Open a new terminal and type

```sh
bli version
```

The output should look similar to this

```sh
BLIMAN {{projectVersion}}
```
