#!/bin/bash
echo ' ########  ########  ######  ##          ###    ########   '
echo ' ##     ## ##       ##    ## ##         ## ##   ##     ##  '
echo ' ##     ## ##       ##       ##        ##   ##  ##     ##  '
echo ' ########  ######    ######  ##       ##     ## ########   '
echo ' ##     ## ##             ## ##       ######### ##     ##  '
echo ' ##     ## ##       ##    ## ##       ##     ## ##     ##  '
echo ' ########  ########  ######  ######## ##     ## ########   '
echo ''
echo ' ##     ##  #######   ######  ########  '
echo ' ##     ## ##     ## ##    ##    ##     '
echo ' ##     ## ##     ## ##          ##     '
echo ' ######### ##     ##  ######     ##     '
echo ' ##     ## ##     ##       ##    ##     '
echo ' ##     ## ##     ## ##    ##    ##     '
echo ' ##     ##  #######   ######     ##     '
echo ''
echo ' ##     ##  #######  ########  ########  '
echo ' ###   ### ##     ## ##     ## ##        '
echo ' #### #### ##     ## ##     ## ##        '
echo ' ## ### ## ##     ## ##     ## ######    '
echo ' ##     ## ##     ## ##     ## ##        '
echo ' ##     ## ##     ## ##     ## ##        '
echo ' ##     ##  #######  ########  ########  '
echo ''

if [[ ! -d $HOME/.oah ]]; then
  	echo "Installing oah-shell"
  	__bliman_secure_curl https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash
	source "$HOME/.oah/bin/oah-init.sh"
else
	echo "oah-shell found"
fi

if [[ ! -d "/c/Program Files/Oracle/VirtualBox" ]]; then
	
	echo "VirtualBox not found".
	echo ""
	echo "Please install VirtualBox to continue"
else
	echo "VirtualBox found"
	VBoxManage --version
fi

if [[ -z "$(command -v vagrant)" ]]; then
	
	echo "Vagrant not found".
	echo ""
	echo "Please install Vagrant to continue"
else
	echo "vagrant found"
	vagrant --version

fi
