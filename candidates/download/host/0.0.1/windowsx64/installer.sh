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
  	__bliman_secure_curl -s https://raw.githubusercontent.com/Be-Secure/oah-installer/master/install.sh | bash
	source "$HOME/.oah/bin/oah-init.sh"
else
	echo "oah-shell found"
fi

if [[ -z $(which virtualbox) ]]; then
  	VIRTUALBOX_URL="https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-Win.exe"

	# Download the VirtualBox installer to the current directory
	wget "$VIRTUALBOX_URL"
	
	# Check if the download was successful
	if [ $? -eq 0 ]; then
	    # Run the VirtualBox installer silently
	    powershell.exe -Command "Start-Process -Wait -FilePath .\VirtualBox-6.1.16-140961-Win.exe -ArgumentList '/S'"
	
	    # Check the installation result
	    if [ $? -eq 0 ]; then
	        echo "Oracle VM VirtualBox has been successfully installed."
	    else
	        echo "VirtualBox installation failed."
	    fi
	else
	    echo "Download of VirtualBox installer failed. Please check your internet connection or the URL."
	fi
else
	echo "virtualbox found"
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
