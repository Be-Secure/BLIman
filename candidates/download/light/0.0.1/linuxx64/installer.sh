#!/bin/bash
echo ' ########  ########  ######  ##          ###    ########   '
echo ' ##     ## ##       ##    ## ##         ## ##   ##     ##  '
echo ' ##     ## ##       ##       ##        ##   ##  ##     ##  '
echo ' ########  ######    ######  ##       ##     ## ########   '
echo ' ##     ## ##             ## ##       ######### ##     ##  '
echo ' ##     ## ##       ##    ## ##       ##     ## ##     ##  '
echo ' ########  ########  ######  ######## ##     ## ########   '
echo ''
echo ' ##       ####  ######   ##     ## ########  '
echo ' ##        ##  ##    ##  ##     ##    ##     '
echo ' ##        ##  ##        ##     ##    ##     '
echo ' ##        ##  ##   #### #########    ##     '
echo ' ##        ##  ##    ##  ##     ##    ##     '
echo ' ##        ##  ##    ##  ##     ##    ##     '
echo ' ######## ####  ######   ##     ##    ##     '
echo ''
echo ' ##     ##  #######  ########  ########  '
echo ' ###   ### ##     ## ##     ## ##        '
echo ' #### #### ##     ## ##     ## ##        '
echo ' ## ### ## ##     ## ##     ## ######    '
echo ' ##     ## ##     ## ##     ## ##        '
echo ' ##     ## ##     ## ##     ## ##        '
echo ' ##     ##  #######  ########  ########  '
echo ''
if [[ ! -d $HOME/.besman ]]; then
	echo "Installing BeSman"
	curl -L "https://raw.githubusercontent.com/Be-Secure/BeSman/dist/dist/get.besman.io" | bash
	source "$HOME"/.besman/bin/besman-init.sh
else
	echo "BeSman found"
fi

