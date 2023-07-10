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
BESLAB_MODE=host
export BESLAB_MODE
echo "Setting lab mode as $BESLAB_MODE"
if [[ ! -d $HOME/.oah ]]; then
  	echo "Installing oah-shell"
  	curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/install.sh | bash
	source "$HOME/.oah/bin/oah-init.sh"
else
	echo "oah-shell found"
fi

if [[ -z $(which virtualbox) ]]; then
  	echo "Installing virtuablbox"
  	sudo apt update
	sudo apt install virtualbox -y
else
	echo "virtualbox found"
fi

if [[ -z $(which vagrant) ]]; then
  	echo "Installing vagrant"
  	wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
	sudo apt install ./vagrant_2.2.19_x86_64.deb
else
	echo "vagrant found"
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
