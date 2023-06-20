#!/bin/bash

echo "BeSlab Light Mode"
if [[ ! -d $HOME/.besman ]]; then
	echo "Installing BeSman"
	curl -L https://raw.githubusercontent.com/Be-Secure/BeSman/dist/dist/get.besman.io | bash
	source $HOME/.besman/bin/besman-init.sh
fi

if ! echo "$BESMAN_ENV_REPOS" | grep -q "Be-Secure/BeSLab"
then
	export BESMAN_ENV_REPOS=$BESMAN_ENV_REPOS,Be-Secure/BeSLab
fi
