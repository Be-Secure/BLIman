#!/bin/bash
echo ' ########  ########  ######  ##          ###    ########   '
echo ' ##     ## ##       ##    ## ##         ## ##   ##     ##  '
echo ' ##     ## ##       ##       ##        ##   ##  ##     ##  '
echo ' ########  ######    ######  ##       ##     ## ########   '
echo ' ##     ## ##             ## ##       ######### ##     ##  '
echo ' ##     ## ##       ##    ## ##       ##     ## ##     ##  '
echo ' ########  ########  ######  ######## ##     ## ########   '
echo ''
echo ' ########     ###    ########  ######## ##     ## ######## ########    ###    ##        '
echo ' ##     ##   ## ##   ##     ## ##       ###   ### ##          ##      ## ##   ##        '
echo ' ##     ##  ##   ##  ##     ## ##       #### #### ##          ##     ##   ##  ##        '
echo ' ########  ##     ## ########  ######   ## ### ## ######      ##    ##     ## ##        '
echo ' ##     ## ######### ##   ##   ##       ##     ## ##          ##    ######### ##        '
echo ' ##     ## ##     ## ##    ##  ##       ##     ## ##          ##    ##     ## ##        '
echo ' ########  ##     ## ##     ## ######## ##     ## ########    ##    ##     ## ########  '
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
  	curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash
	source "$HOME/.oah/bin/oah-init.sh"
else
	echo "oah-shell found"
fi

if [[ -z $(which ansible) ]]; then
	echo "Installing ansible"
	sudo apt update
	sudo apt-add-repository --yes ppa:ansible/ansible
	sudo apt update
	sudo apt install ansible -y
else
	echo "Ansible found"
fi
