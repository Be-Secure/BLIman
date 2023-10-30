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

# if [[ ! -d $HOME/.oah ]]; then
#   	echo "Installing oah-shell"
#   	__bliman_secure_curl https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash
# 	source "$HOME/.oah/bin/oah-init.sh"
# else
# 	echo "oah-shell found"
# fi

if ! echo "$PATH" | grep -q "VirtualBox"
then
	echo "Downloading Oracle VM VirtualBox"
	curl -k -s -L https://download.virtualbox.org/virtualbox/7.0.12/VirtualBox-7.0.12-159484-Win.exe >> "$BLIMAN_DIR/tmp/virtualbox.exe"
	./"$BLIMAN_DIR"/tmp/virtualbox.exe

else
	echo "VirtualBox found"
fi

# if [[ -z $(which vagrant) ]]; then
#   	echo "Installing vagrant"
#   	wget https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
# 	sudo apt install ./vagrant_2.2.19_x86_64.deb
# else
# 	echo "vagrant found"
# fi

# if [[ -z $(which ansible) ]]; then
# 	echo "Installing ansible"
# 	sudo apt update
# 	sudo apt-add-repository --yes ppa:ansible/ansible
# 	sudo apt update
# 	sudo apt install ansible -y
# else
# 	echo "Ansible found"
# fi
