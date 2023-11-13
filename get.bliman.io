#!/bin/bash
# install:- channel: stable; cliVersion: 5.18.1; cliNativeVersion: 0.2.9; api: https://api.bliman.io/2

track_last_command() {
	last_command=$current_command
	current_command=$BASH_COMMAND
}

echo_failed_command() {
	local exit_code="$?"
	if [[ "$exit_code" != "0" ]]; then
		echo "'$last_command': command failed with exit code $exit_code."
	fi
}

function infer_platform() {
	local kernel
	local machine

	kernel="$(uname -s)"
	machine="$(uname -m)"

	case $kernel in
	Linux)
		case $machine in
		i686)
			echo "linuxx32"
			;;
		x86_64)
			echo "linuxx64"
			;;
		armv6l)
			echo "linuxarm32hf"
			;;
		armv7l)
			echo "linuxarm32hf"
			;;
		armv8l)
			echo "linuxarm32hf"
			;;
		aarch64)
			echo "linuxarm64"
			;;
		*)
			echo "exotic"
			;;
		esac
		;;
	Darwin)
		case $machine in
		x86_64)
			echo "darwinx64"
			;;
		arm64)
			if [[ "$bliman_rosetta2_compatible" == 'true' ]]; then
				echo "darwinx64"
			else
				echo "darwinarm64"
			fi
			;;
		*)
			echo "darwinx64"
			;;
		esac
		;;
	MSYS* | MINGW*)
		case $machine in
		x86_64)
			echo "windowsx64"
			;;
		*)
			echo "exotic"
			;;
		esac
		;;
	*)
		echo "exotic"
		;;
	esac
}

function __bliman_quick_install() {

	set -e
	trap track_last_command DEBUG
	trap echo_failed_command EXIT

	# Global variables
	export BLIMAN_SERVICE="https://raw.githubusercontent.com"
	export BLIMAN_NAMESPACE="Be-Secure"
	export BLIMAN_REPO_URL="$BLIMAN_SERVICE/$BLIMAN_NAMESPACE/BLIman/main"
	export BLIMAN_VERSION="0.3.0"
	export BLIMAN_LAB_URL="$BLIMAN_SERVICE/$BLIMAN_NAMESPACE/BeSLab/main"
	
	# export BLIMAN_NATIVE_VERSION="0.2.9"
	# infer platform

	BLIMAN_PLATFORM="$(infer_platform)"
	export BLIMAN_PLATFORM

	if [ -z "$BLIMAN_DIR" ]; then
		BLIMAN_DIR="$HOME/.bliman"
		BLIMAN_DIR_RAW="$HOME/.bliman"
	else
		BLIMAN_DIR_RAW="$BLIMAN_DIR"
	fi
	export BLIMAN_DIR

	# Local variables
	bliman_src_folder="${BLIMAN_DIR}/src"
	bliman_tmp_folder="${BLIMAN_DIR}/tmp"
	bliman_ext_folder="${BLIMAN_DIR}/ext"
	bliman_etc_folder="${BLIMAN_DIR}/etc"
	bliman_var_folder="${BLIMAN_DIR}/var"
	bliman_candidates_folder="${BLIMAN_DIR}/candidates"
	bliman_config_file="${bliman_etc_folder}/config"
	bliman_bash_profile="${HOME}/.bash_profile"
	bliman_bashrc="${HOME}/.bashrc"
	bliman_zshrc="${ZDOTDIR:-${HOME}}/.zshrc"

	bliman_init_snippet=$(
		cat <<EOF
#THIS MUST BE AT THE END OF THE FILE FOR BLIMAN TO WORK!!!
export BLIMAN_DIR="$BLIMAN_DIR_RAW"
[[ -s "${BLIMAN_DIR_RAW}/bin/bliman-init.sh" ]] && source "${BLIMAN_DIR_RAW}/bin/bliman-init.sh"
EOF
	)

	# OS specific support (must be 'true' or 'false').
	cygwin=false
	darwin=false
	solaris=false
	freebsd=false
	case "$(uname)" in
	CYGWIN*)
		cygwin=true
		;;
	Darwin*)
		darwin=true
		;;
	SunOS*)
		solaris=true
		;;
	FreeBSD*)
		freebsd=true
		;;
	esac

	echo ' BBBBBBBBBBBBBBBBB   LLLLLLLLLLL             IIIIIIIIIIMMMMMMMM               MMMMMMMM               AAA               NNNNNNNN        NNNNNNNN '
	echo ' B::::::::::::::::B  L:::::::::L             I::::::::IM:::::::M             M:::::::M              A:::A              N:::::::N       N::::::N '
	echo ' B::::::BBBBBB:::::B L:::::::::L             I::::::::IM::::::::M           M::::::::M             A:::::A             N::::::::N      N::::::N '
	echo ' BB:::::B     B:::::BLL:::::::LL             II::::::IIM:::::::::M         M:::::::::M            A:::::::A            N:::::::::N     N::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M::::::::::M       M::::::::::M           A:::::::::A           N::::::::::N    N::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M:::::::::::M     M:::::::::::M          A:::::A:::::A          N:::::::::::N   N::::::N '
	echo '   B::::BBBBBB:::::B   L:::::L                 I::::I  M:::::::M::::M   M::::M:::::::M         A:::::A A:::::A         N:::::::N::::N  N::::::N '
	echo '   B:::::::::::::BB    L:::::L                 I::::I  M::::::M M::::M M::::M M::::::M        A:::::A   A:::::A        N::::::N N::::N N::::::N '
	echo '   B::::BBBBBB:::::B   L:::::L                 I::::I  M::::::M  M::::M::::M  M::::::M       A:::::A     A:::::A       N::::::N  N::::N:::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M::::::M   M:::::::M   M::::::M      A:::::AAAAAAAAA:::::A      N::::::N   N:::::::::::N '
	echo '   B::::B     B:::::B  L:::::L                 I::::I  M::::::M    M:::::M    M::::::M     A:::::::::::::::::::::A     N::::::N    N::::::::::N '
	echo '   B::::B     B:::::B  L:::::L         LLLLLL  I::::I  M::::::M     MMMMM     M::::::M    A:::::AAAAAAAAAAAAA:::::A    N::::::N     N:::::::::N '
	echo ' BB:::::BBBBBB::::::BLL:::::::LLLLLLLLL:::::LII::::::IIM::::::M               M::::::M   A:::::A             A:::::A   N::::::N      N::::::::N '
	echo ' B:::::::::::::::::B L::::::::::::::::::::::LI::::::::IM::::::M               M::::::M  A:::::A               A:::::A  N::::::N       N:::::::N '
	echo ' B::::::::::::::::B  L::::::::::::::::::::::LI::::::::IM::::::M               M::::::M A:::::A                 A:::::A N::::::N        N::::::N '

	# Sanity checks

	echo "Looking for a previous installation of BLIMAN..."
	if [ -d "$BLIMAN_DIR" ]; then
		echo "BLIMAN found."
		echo ""
		echo "======================================================================================================"
		echo " You already have BLIMAN installed."
		echo " BLIMAN was found at:"
		echo ""
		echo "    ${BLIMAN_DIR}"
		echo ""
		echo " Please consider running the following if you need to upgrade."
		echo ""
		echo "    $ bli selfupdate force"
		echo ""
		echo "======================================================================================================"
		echo ""
		exit 0
	fi

	# echo "Looking for unzip..."
	# if ! command -v unzip > /dev/null; then
	# 	echo "Not found."
	# 	echo "======================================================================================================"
	# 	echo " Please install unzip on your system using your favourite package manager."
	# 	echo ""
	# 	echo " Restart after installing unzip."
	# 	echo "======================================================================================================"
	# 	echo ""
	# 	exit 1
	# fi

	# echo "Looking for zip..."
	# if ! command -v zip > /dev/null; then
	# 	echo "Not found."
	# 	echo "======================================================================================================"
	# 	echo " Please install zip on your system using your favourite package manager."
	# 	echo ""
	# 	echo " Restart after installing zip."
	# 	echo "======================================================================================================"
	# 	echo ""
	# 	exit 1
	# fi

	# echo "Looking for curl..."
	# if ! command -v curl > /dev/null; then
	# 	echo "Not found."
	# 	echo ""
	# 	echo "======================================================================================================"
	# 	echo " Please install curl on your system using your favourite package manager."
	# 	echo ""
	# 	echo " Restart after installing curl."
	# 	echo "======================================================================================================"
	# 	echo ""
	# 	exit 1
	# fi

	if [[ "$solaris" == true ]]; then
		echo "Looking for gsed..."
		if [ -z $(which gsed) ]; then
			echo "Not found."
			echo ""
			echo "======================================================================================================"
			echo " Please install gsed on your solaris system."
			echo ""
			echo " BLIMAN uses gsed extensively."
			echo ""
			echo " Restart after installing gsed."
			echo "======================================================================================================"
			echo ""
			exit 1
		fi
	else
		echo "Looking for sed..."
		if [ -z $(command -v sed) ]; then
			echo "Not found."
			echo ""
			echo "======================================================================================================"
			echo " Please install sed on your system using your favourite package manager."
			echo ""
			echo " Restart after installing sed."
			echo "======================================================================================================"
			echo ""
			exit 1
		fi
	fi

	echo "Installing BLIMAN scripts..."

	# Create directory structure

	echo "Create distribution directories..."
	mkdir -p "$bliman_tmp_folder"
	mkdir -p "$bliman_ext_folder"
	mkdir -p "$bliman_etc_folder"
	mkdir -p "$bliman_var_folder"
	mkdir -p "$bliman_candidates_folder"
	mkdir -p "$bliman_src_folder"

	echo "Getting available candidates..."
	echo "from ${BLIMAN_REPO_URL}/candidates.txt"
	BLIMAN_CANDIDATES_CSV=$(curl -s -k "${BLIMAN_REPO_URL}/candidates.txt")
	echo "$BLIMAN_CANDIDATES_CSV" >"${BLIMAN_DIR}/var/candidates"

	echo "Prime the config file..."
	touch "$bliman_config_file"
	echo "bliman_auto_answer=false" >>"$bliman_config_file"
	if [ -z "$ZSH_VERSION" -a -z "$BASH_VERSION" ]; then
		echo "bliman_auto_complete=false" >>"$bliman_config_file"
	else
		echo "bliman_auto_complete=false" >>"$bliman_config_file"
	fi
	touch "$bliman_config_file"
	{
		echo "bliman_auto_env=false"
		echo "bliman_auto_update=true"
		echo "bliman_beta_channel=false"
		echo "bliman_checksum_enable=true"
		echo "bliman_colour_enable=true"
		echo "bliman_curl_connect_timeout=7"
		echo "bliman_curl_max_time=10"
		echo "bliman_debug_mode=false"
		echo "bliman_insecure_ssl=false"
		echo "bliman_rosetta2_compatible=false"
		echo "bliman_selfupdate_feature=true"
	} >>"$bliman_config_file"

	# script cli distribution
	echo "Installing script cli archive..."
	# fetch distribution
	bliman_zip_file="${bliman_tmp_folder}/bliman-${BLIMAN_VERSION}.zip"
	echo "* Downloading..."
    curl -s -k --location --progress-bar "${BLIMAN_SERVICE}/${BLIMAN_NAMESPACE}/BLIman/dist/dist/bliman-latest.zip" > "$bliman_zip_file"

	# check integrity
	echo "* Checking archive integrity..."
	ARCHIVE_OK=$(unzip -qt "$bliman_zip_file" | grep 'No errors detected in compressed data')
	if [[ -z "$ARCHIVE_OK" ]]; then
		echo "Downloaded zip archive corrupt. Are you connected to the internet?"
		echo ""
		echo "If problems persist, please raise an issue in:"
		echo "* https://github.com/Be-Secure/BLIman/issues"
		exit
	fi

	# extract archive
	echo "* Extracting archive..."
	if [[ "$cygwin" == 'true' ]]; then
		bliman_tmp_folder=$(cygpath -w "$bliman_tmp_folder")
		bliman_zip_file=$(cygpath -w "$bliman_zip_file")
	fi
	unzip -qo "$bliman_zip_file" -d "$bliman_tmp_folder"

	# copy in place
	echo "* Copying archive contents..."
	#cp -r "contrib/" "$BLIMAN_DIR"
	#cp -r "src/main/bash" "$bliman_src_folder"
	mkdir -p "$BLIMAN_DIR/bin/"
	cp -rf "${bliman_tmp_folder}"/bliman-* "$bliman_src_folder"
	mv "$bliman_src_folder"/bliman-init.sh "$BLIMAN_DIR/bin/"

	# clean up
	echo "* Cleaning up..."
	rm -rf "$bliman_tmp_folder"/bliman-*.sh
	rm -rf "$bliman_zip_file"

	echo ""

	# # native cli distribution
	# if [[ "$BLIMAN_PLATFORM" != "exotic" ]]; then
	# # fetch distribution
	# bliman_zip_file="${bliman_tmp_folder}/bliman-native-${BLIMAN_NATIVE_VERSION}.zip"
	# echo "* Downloading..."
	# curl --fail --location --progress-bar "${BLIMAN_SERVICE}/broker/download/native/install/${BLIMAN_NATIVE_VERSION}/${BLIMAN_PLATFORM}" > "$bliman_zip_file"

	# # check integrity
	# echo "* Checking archive integrity..."
	# ARCHIVE_OK=$(unzip -qt "$bliman_zip_file" | grep 'No errors detected in compressed data')
	# if [[ -z "$ARCHIVE_OK" ]]; then
	# 	echo "Downloaded zip archive corrupt. Are you connected to the internet?"
	# 	echo ""
	# 	echo "If problems persist, please ask for help on our Slack:"
	# 	echo "* easy sign up: https://slack.bliman.io/"
	# 	echo "* report on channel: https://bliman.slack.com/app_redirect?channel=user-issues"
	# 	exit
	# fi

	# # extract archive
	# echo "* Extracting archive..."
	# if [[ "$cygwin" == 'true' ]]; then
	# 	bliman_tmp_folder=$(cygpath -w "$bliman_tmp_folder")
	# 	bliman_zip_file=$(cygpath -w "$bliman_zip_file")
	# fi
	# unzip -qo "$bliman_zip_file" -d "$bliman_tmp_folder"

	# # copy in place
	# echo "* Copying archive contents..."
	# rm -f "$bliman_libexec_folder"/*
	# cp -rf "${bliman_tmp_folder}"/bliman-*/* "$BLIMAN_DIR"

	# # clean up
	# echo "* Cleaning up..."
	# rm -rf "$bliman_tmp_folder"/bliman-*
	# rm -rf "$bliman_zip_file"

	# echo ""
	# fi

	echo "Set version to $BLIMAN_VERSION ..."
	echo "$BLIMAN_VERSION" >"${BLIMAN_DIR}/var/version"

	echo "Set native version to $BLIMAN_NATIVE_VERSION ..."
	echo "$BLIMAN_NATIVE_VERSION" >"${BLIMAN_DIR}/var/version_native"

	if [[ $darwin == true ]]; then
		touch "$bliman_bash_profile"
		echo "Attempt update of login bash profile on OSX..."
		if [[ -z $(grep 'bliman-init.sh' "$bliman_bash_profile") ]]; then
			echo -e "\n$bliman_init_snippet" >>"$bliman_bash_profile"
			echo "Added bliman init snippet to $bliman_bash_profile"
		fi
	else
		echo "Attempt update of interactive bash profile on regular UNIX..."
		touch "${bliman_bashrc}"
		if [[ -z $(grep 'bliman-init.sh' "$bliman_bashrc") ]]; then
			echo -e "\n$bliman_init_snippet" >>"$bliman_bashrc"
			echo "Added bliman init snippet to $bliman_bashrc"
		fi
	fi

	echo "Attempt update of zsh profile..."
	touch "$bliman_zshrc"
	if [[ -z $(grep 'bliman-init.sh' "$bliman_zshrc") ]]; then
		echo -e "\n$bliman_init_snippet" >>"$bliman_zshrc"
		echo "Updated existing ${bliman_zshrc}"
	fi

	__bliman_load_genesis_file
	__bliman_write_tmpl_vagrantfile

	echo -e "\n\n\nAll done!\n\n"

	echo "You are subscribed to the STABLE channel."

	echo ""
	echo "Please open a new terminal, or run the following in the existing one:"
	echo ""
	echo "    source \"${BLIMAN_DIR}/bin/bliman-init.sh\""
	echo ""
	echo "Then issue the following command:"
	echo ""
	echo "    bli help"
	echo ""
	echo "Enjoy!!!"

}

function __bliman_write_tmpl_vagrantfile()
{
	local vagrantfile_path
	vagrantfile_path="$BLIMAN_DIR/tmp/Vagrantfile"
	touch "$vagrantfile_path"
	cat <<EOF >>"$vagrantfile_path"
# # -*- mode: ruby -*-
# # vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version '>= 1.8.1'


# Cross-platform way of finding an executable in the \$PATH.
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

# Use oah-config.yml for basic VM configuration.
require 'yaml'


#dir = File.dirname(File.expand_path(__FILE__))
dir = File.dirname("../../../")

if !File.exist?("#{dir}/oah-config.yml")
  raise "Configuration file #{dir}/oah-config.yml not found!  Please copy example.oah-config.yml to oah-config.yml and try again."
end
vconfig = YAML::load_file("#{dir}/oah-config.yml")


\$script = <<SCRIPT
echo "create user vagrant"
adduser --disabled-password --gecos "" vagrant
echo 'vagrant:vagrant' | chpasswd
ls -al /home/
echo "add sudo privilege to user vagrant"
cp /etc/sudoers.d/90-cloud-init-users /etc/sudoers.d/admin
chmod +w /etc/sudoers.d/admin
ls -al /etc/sudoers.d/
sed -i 's/ubuntu/vagrant/g' /etc/sudoers.d/admin
cat /etc/sudoers.d/admin
echo "enable ssh access for user vagrant"
echo "generating authorized_keys"
ls /home/ubuntu/.ssh/
cp /home/ubuntu/.ssh/id_rsa.pub /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
mkdir -p /home/vagrant/.ssh
echo "listing contents of under /home/ubuntu/.ssh"
ls /home/ubuntu/.ssh
chown vagrant:vagrant /home/vagrant/.ssh
cat /home/ubuntu/.ssh/authorized_keys >> /home/vagrant/.ssh/authorized_keys
echo "value of authorized_keys under ubuntu"
cat /home/ubuntu/.ssh/authorized_keys
echo "value of authorized_keys under vagrant"
cat /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
su - vagrant -c "cat /home/vagrant/.ssh/authorized_keys"
chmod 600 /home/vagrant/.ssh/authorized_keys
ls -al /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
ls -al /home/vagrant
sudo apt update -y
sudo apt-get install -y --no-install-recommends ansible
sudo apt full-upgrade -y
sudo apt-get autoremove -y
test -e /usr/bin/python || (sudo apt -y update && apt install -y python-minimal)
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily.timer
SCRIPT


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = vconfig['vagrant_hostname']
  config.vm.box = vconfig['vagrant_box']
  if vconfig['vagrant_ip'] == "0.0.0.0" && Vagrant.has_plugin?("vagrant-auto_network")
    config.vm.network :private_network, :ip => vconfig['vagrant_ip'], :auto_network => true
  else
    config.vm.network :private_network, ip: vconfig['vagrant_ip']
  end

  if !vconfig['vagrant_public_ip'].empty? && vconfig['vagrant_public_ip'] == "0.0.0.0"
    config.vm.network :public_network
  elsif !vconfig['vagrant_public_ip'].empty?
    config.vm.network :public_network, ip: vconfig['vagrant_public_ip']
  end

  # # Autoconfigure hosts. This will copy the private network addresses from
  # # each VM and update hosts entries on all other machines. No further
  # # configuration is needed.
  # Vagrant.configure('2') do |config|

  #   config.vm.define :first do |node|
  #     node.vm.box = ""
  #     node.vm.network :private_network, :ip => '10.20.1.2'
  #     node.vm.provision :hosts, :sync_hosts => true
  #   end

  #   config.vm.define :second do |node|
  #     node.vm.box = "ubuntu/bionic64"
  #     node.vm.network :private_network, :ip => '10.20.1.3'
  #     node.vm.provision :hosts, :sync_hosts => true
  #   end
  # end

  # config.ssh.insert_key = true
  # config.ssh.forward_agent = true
  # config.ssh.username = vconfig['vagrant_user']

  Vagrant.configure("2") do |config|
    config.vm.provision "ansible" do |ansible|
      ansible.version = "2.14.4" # Specify the version you want to useend
    end
    config.ssh.insert_key = true
    config.ssh.private_key_path = "~/.ssh/id_rsa"
    config.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']
    config.ssh.forward_agent = true
    config.ssh.username = vconfig['vagrant_user']
  end

  #config.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']


  # If hostsupdater plugin is installed, add all server names as aliases.
  # if Vagrant.has_plugin?("vagrant-hostsupdater")
  #   config.hostsupdater.aliases = []
  #   # Add all hosts that aren't defined as Ansible vars.
  #   if vconfig['oahvm_webserver'] == "apache"
  #     for host in vconfig['apache_vhosts']
  #       unless host['servername'].include? "{{"
  #         config.hostsupdater.aliases.push(host['servername'])
  #       end
  #     end
  #   else
  #     for host in vconfig['nginx_hosts']
  #       unless host['server_name'].include? "{{"
  #         config.hostsupdater.aliases.push(host['server_name'])
  #       end
  #     end
  #   end
  # end

  for synced_folder in vconfig['vagrant_synced_folders'];
    config.vm.synced_folder synced_folder['local_path'], synced_folder['destination'],
      type: synced_folder['type'],
      rsync__auto: "true",
      rsync__exclude: synced_folder['excluded_paths'],
      rsync__args: ["--verbose", "--archive", "--delete", "-z", "--chmod=ugo=rwX"],
      id: synced_folder['id'],
      create: synced_folder.include?('create') ? synced_folder['create'] : false,
      mount_options: synced_folder.include?('mount_options') ? synced_folder['mount_options'] : []
  end
  
  beslab_user = ENV['BESLAB_USER']
  beslab_password = ENV['BESLAB_PWD']
  bliman_dir = ENV['BLIMAN_DIR']
  oah_dir = ENV['OAH_DIR']

  if which('ansible-playbook')
    # Provision using Ansible provisioner if Ansible is installed on host.
    bliman_dir = ENV['BLIMAN_DIR']
    config.vm.provision "shell", path: "#{bliman_dir}/tmp/source.sh"
    config.vm.provision "shell", inline: <<-SHELL, env: { "BESLAB_USER" => beslab_user, "BESLAB_USER_PASSWORD" => beslab_password }
		encrypted_password=$(openssl passwd -1 \$BESLAB_USER_PASSWORD)
		# sudo userdel -r "\$BESLAB_USER"
		sudo useradd -m -p "\$encrypted_password" "\$BESLAB_USER"
		sudo usermod -aG sudo "\$BESLAB_USER"
		cp -r /home/vagrant/.ssh /home/\$BESLAB_USER/
		chown \$BESLAB_USER:\$BESLAB_USER /home/\$BESLAB_USER/.ssh/authorized_keys
    SHELL

    config.vm.provision "ansible" do |ansible|
	  command = ENV['BLIMAN_COMMAND']
      ansible.playbook = "#{dir}/provisioning/oah-#{command}.yml"
      ansible.galaxy_role_file = "#{dir}/provisioning/oah-requirements.yml"
      ansible.become = true                                                                                                                
    end
  else
	config.vm.provision "shell", inline: <<-SHELL, env: {"BESLAB_USER" => beslab_user, "BESLAB_USER_PASSWORD" => beslab_password }
		encrypted_password=\$(openssl passwd -1 \$BESLAB_USER_PASSWORD)
		# sudo userdel -r "\$BESLAB_USER"
		sudo useradd -m -p "\$encrypted_password" "\$BESLAB_USER"
		sudo usermod -aG sudo "\$BESLAB_USER"
		cp -r /home/vagrant/.ssh /home/\$BESLAB_USER/
		chown \$BESLAB_USER:\$BESLAB_USER /home/\$BESLAB_USER/.ssh/authorized_keys
		mkdir -p /home/\$BESLAB_USER/oah-bes-vm
		mkdir -p /home/\$BESLAB_USER/bliman_tmp
	SHELL

	config.vm.synced_folder "#{bliman_dir}/tmp", "/home/#{beslab_user}/bliman_tmp"
	config.vm.synced_folder "#{oah_dir}/data/env/oah-bes-vm", "/home/#{beslab_user}/oah-bes-vm"

	config.vm.provision "shell", inline: <<-SHELL, env: {"BESLAB_USER" => beslab_user, "BESLAB_USER_PASSWORD" => beslab_password }
		sudo apt-add-repository ppa:ansible/ansible
		sudo apt update
		sudo apt install ansible -y
		source /home/\$BESLAB_USER/bliman_tmp/source.sh
		mkdir -p "/home/\$BESLAB_USER/oah-bes-vm/roles"
		ansible-galaxy install -r /home/\$BESLAB_USER/oah-bes-vm/provisioning/oah-requirements.yml -p /home/\$BESLAB_USER/oah-bes-vm/provisioning/roles
		ansible-playbook /home/\$BESLAB_USER/oah-bes-vm/provisioning/oah-install.yml --ask-become-pass
	SHELL
  end


  # VirtualBox.
  config.vm.provider :virtualbox do |v|
    v.name = vconfig['vagrant_hostname']
    v.memory = vconfig['vagrant_memory']
    v.cpus = vconfig['vagrant_cpus']
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    v.gui=vconfig['oah_vm_gui']
  end
  config.vm.define vconfig['vagrant_machine_name'] do |d|
  end
end
EOF
}
function __bliman_load_genesis_file() {
	local genesis_file_name genesis_file_url
	genesis_file_name="beslab_genesis.yaml"
	genesis_file_url="$BLIMAN_LAB_URL/$genesis_file_name"

	if [[ -f "$HOME/$genesis_file_name" ]]; then

		echo "Using genesis file found @ $HOME"
		export BLIMAN_GENSIS_FILE_PATH="$HOME/$genesis_file_name"
		echo "Setting genesis file path as $BLIMAN_GENSIS_FILE_PATH"
	else
		echo "Using default genesis file @ $genesis_file_url"
		export BLIMAN_GENSIS_FILE_PATH="$BLIMAN_DIR/tmp/$genesis_file_name"
		echo "Setting genesis file path as $BLIMAN_GENSIS_FILE_PATH"
		__bliman_check_genesis_file_available "$genesis_file_url" || return 1
		__bliman_get_genesis_file "$genesis_file_url" "$BLIMAN_GENSIS_FILE_PATH"
	fi
	__bliman_load_export_vars "$BLIMAN_GENSIS_FILE_PATH"
}

function __bliman_check_genesis_file_available() {
	local url response
	url=$1
	echo "Checking if genesis file available @ $url"
	response=$(curl -k --head --silent "$url" | head -n 1 | awk '{print $2}')
	if [[ $response -eq 200 ]]; then
		echo "Genesis file found"
		return 0
	else
		echo "Could not find genesis file @ $url"
		return 1
	fi

}

function __bliman_get_genesis_file() {
	local url default_genesis_file_path
	url=$1
	default_genesis_file_path=$2
	[[ -f "$default_genesis_file_path" ]] && rm "$default_genesis_file_path"
	touch "$default_genesis_file_path"
	echo "Downloading genesis file"
	curl -k -sL "$url" >>"$default_genesis_file_path"

}


function __bliman_convert_yaml_to_sh()
{
	local genesis_data source_file
	genesis_data=$1
	source_file=$2

	while read -r key 
	do
		echo "$key" | sed "s/:/=/" | sed "s/ //g" >> "$HOME/tmp.sh"
	done <<< "$genesis_data" 

	multi_values=""
	multi_values_flag=false
	echo "#!/bin/bash" >> "$source_file"
	while read -r line 
	do
		if echo "$line" | grep -qe "^#" 
		then
			continue
		fi
		if [[ ( "$line" == "" ) || ( $line == "---" ) ]] 
		then
			continue
		fi
		key=$(echo "$line" | cut -d "=" -f 1)
		value=$(echo "$line" | cut -d "=" -f 2)
		if [ $multi_values_flag == true ] && ! echo "$key" | grep -qe "^-" 
		then
			multi_values_flag=false
			echo "export $key_save=$multi_values" | sed "s/,//1" >> "$source_file"
			multi_values=""
		fi
		if [[ "$line" == "" ]]; then
			multi_values_flag=false
			echo "export $key_save=$multi_values" | sed "s/,//1" >> "$source_file"
			multi_values=""
		fi
		if [[ $value == "" ]]; then
			multi_values_flag=true
			key_save=$key
			continue
		elif [[ $multi_values_flag == false ]] 
		then
			
			echo "export $key=$value" >> "$source_file"
		fi
		if [[ $multi_values_flag == "true" ]] 
		then
			if echo "$line" | grep -qe "^-" 
			then
				value_2=$(echo "$line" | sed "s/-//1")
				multi_values+=",$value_2"
				continue

			else
				multi_values_flag=false
				echo "export $key_save=$multi_values"
			fi
		fi
	done < "$HOME/tmp.sh"

	if ! grep "$key_save" "$source_file" 
	then
		echo "export $key_save=$multi_values" | sed "s/,//1" >> "$source_file"
	fi

	[[ -f "$HOME/tmp.sh" ]] && rm "$HOME/tmp.sh"
}

function __bliman_load_export_vars() {
	local genesis_file_path source_file genesis_data
	echo "Loading genesis file parameters"
	genesis_file_path=$1
	sed -i '/^$/d' "$genesis_file_path" # Delete empty lines
	genesis_data=$(<"$genesis_file_path")
	source_file="$BLIMAN_DIR/tmp/source.sh"
	__bliman_convert_yaml_to_sh "$genesis_data" "$source_file"
}




__bliman_quick_install
