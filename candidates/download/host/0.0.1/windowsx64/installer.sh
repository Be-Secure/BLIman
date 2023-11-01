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
	
	[[ -f "$BLIMAN_DIR/tmp/virtualbox.exe" ]] && rm "$BLIMAN_DIR/tmp/virtualbox.exe"
	echo "Downloading Oracle VM VirtualBox"
	curl --fail --location --progress-bar --insecure https://download.virtualbox.org/virtualbox/7.0.12/VirtualBox-7.0.12-159484-Win.exe > "$BLIMAN_DIR/tmp/virtualbox.exe"
	cd "$BLIMAN_DIR/tmp" || return 1
	echo "Please follow the steps in installation wizard"
	./virtualbox.exe
else
	echo "VirtualBox found"
fi

if [[ -z "$(command -v vagrant)" ]]; then
	
	echo "Downloading vagrant"
	curl --fail --location --progress-bar --insecure https://releases.hashicorp.com/vagrant/2.4.0/vagrant_2.4.0_windows_amd64.msi > "$BLIMAN_DIR/tmp/vagrant.msi"
	cd "$BLIMAN_DIR/tmp/vagrant.msi" || return 1
	"$BLIMAN_DIR/tmp/vagrant.msi"
	msiexec /i vagrant.msi
else

	echo "vagrant found"

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
