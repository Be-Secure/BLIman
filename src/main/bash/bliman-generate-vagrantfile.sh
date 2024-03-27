#!/usr/bin/env bash

#
#   Copyright 2023 BeS Community
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

function __bli_generate_vagrantfile()
{
	local vagrantfile_path
	if [ ! -z $BLIMAN_DIR ];then
	   vagrantfile_path="$BLIMAN_DIR/tmp/Vagrantfile"
	else
           vagrantfile_path="$HOME/.bliman/tmp/Vagrantfile"
        fi

        __bliman_echo_yellow "Generating vagrant file at $vagrantfile_path"

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
__bliman_echo_green "Generated vagrantfile at $vagrantfile_path"
}
