#!/bin/bash
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

function __bliman_launch_host_mode() {
	__bliman_clone_substrate
	__bliman_generate_vm_roles
	__bliman_generate_vm_config
	__bliman_prime_vagrantfile
	__bliman_prime_installer_playbook
	__bliman_launch_bes_lab_host_mode
}

function __bliman_launch_bare_mode() {
	export BESLAB_VM_GUI=false
	__bliman_clone_substrate
	__bliman_generate_vm_roles
	__bliman_generate_vm_config
	__bliman_prime_installer_playbook
	__bliman_launch_bes_lab_bare_metal_mode

}

function __bliman_launch_lite_mode() {
	__bliman_check_besman || return 1
	__bliman_set_env_repo || return 1
	__bliman_install_beslab_env
}

function __bliman_prime_vagrantfile() {
	__bliman_echo_yellow "Prime vagrantfile"
	[[ -f $HOME/oah-bes-vm/host/vagrant/Vagrantfile ]] && rm "$HOME/oah-bes-vm/host/vagrant/Vagrantfile"
	cp "$BLIMAN_DIR/tmp/Vagrantfile" "$HOME/oah-bes-vm/host/vagrant/Vagrantfile" | __bliman_log
}

function __bliman_clone_substrate() {
	__bliman_echo_yellow "Setting OAH_ENV_BASE as $HOME"
	OAH_ENV_BASE="$HOME"
	export OAH_ENV_BASE
	__bliman_echo_yellow "OAH_ENV_BASE=$OAH_ENV_BASE"
	[[ -d "$HOME/oah-bes-vm" ]] && echo "oah-bes-vm found" && return
	git clone "https://github.com/$BLIMAN_NAMESPACE/oah-bes-vm" "$HOME/oah-bes-vm" | __bliman_log
	}

function __bliman_set_env_repo() {
	__bliman_echo_yellow "Set BeSMan environment."
	#bes set BESMAN_LITE_MODE True
	#bes unset BESMAN_LOCAL_ENV
	bes set BESMAN_ENV_REPOS "$BLIMAN_NAMESPACE/BeSLab" || return 1
	__bliman_echo_yellow "Installing BeSLab to besman envs."

	[[ -z $GITHUB_BROWSER_URL ]] && export GITHUB_BROWSER_URL="https://github.com"
        [[ -z $GITHUB_NAMESPSCE ]] && export GITHUB_NAMESPACE="Be-Secure"

        tmp_location="/tmp"
        unzip_location="/tmp/BeSLab"
	if [ ! -z $BESLAB_VERSION ] && [ "$BESLAB_VERSION" == "latest" ];then

           response=$(curl -s "https://api.github.com/repos/$BLIMAN_NAMESPACE/BeSLab/releases/latest")
           __bliman_echo_yellow "Installing JQ for JSON response readings."
	   which jq
	   if [ xx"$?" != xx"0" ];then
              apt-get install jq -y | __bliman_log
           fi
	   latest_rel=$(echo "$response" | jq -r '.tag_name')

	   if [ ! -z $latest_rel ];then

             unset $BESLAB_VERSION
	     export BESLAB_VERSION="$latest_rel"

	     [[ -d $unzip_location ]] && rm -rf $unzip_location

             curl -o $tmp_location/beslab-${latest_rel}.zip --fail --location --progress-bar "${GITHUB_BROWSER_URL}/${GITHUB_NAMESPACE}/BeSLab/archieve/refs/tags/${latest_rel}.zip" | __bliman_log

	     unzip -qo $tmp_location/beslab-${latest_rel}.zip -d $unzip_location | __bliman_log
             #mkdir -p "$HOME/.besman/envs/${latest_rel}" | __bliman_log
	     #cp "$unzip_location/src/*" "$HOME/.besman/envs/${latest_rel}" | __bliman_log
             cp $unzip_location/src/* "$HOME/.besman/envs/" | __bliman_log

	     rm -rf $unzip_location
	     rm -f  $tmp_location/beslab-${latest_rel}.zip

           else
               __bliman_echo_red "no latest release found for BeSLab in the namespace $BLIMAN_NAMESPACE"
	       __bliman_echo_red "Please specify the correct namespace or specific version and try again."
	       __bliman_echo_red "exiting..."
	       return 1
           fi
        elif [ ! -z $BESLAB_VERSION ] && [ "$BESLAB_VERSION" != "latest" ] && [ "$BESLAB_VERSION" != "dev" ];then

            [[ -d $unzip_location ]] && rm -rf $unzip_location

             curl -o $tmp_location/beslab-${BESLAB_VERSION}.zip --fail --location --progress-bar "${GITHUB_BROWSER_URL}/${GITHUB_NAMESPACE}/BeSLab/archieve/refs/tags/${BESLAB_VERSION}.zip" | __bliman_log

             unzip -qo $tmp_location/beslab-${BESLAB_VERSION}.zip -d $unzip_location | __bliman_log
             #mkdir -p "$HOME/.besman/envs/${BESLAB_VERSION}" | __bliman_log
             #cp "$unzip_location/src/*" "$HOME/.besman/envs/${BESLAB_VERSION}" | __bliman_log
             cp $unzip_location/src/* "$HOME/.besman/envs/" | __bliman_log

             rm -rf $unzip_location
             rm -f  $tmp_location/beslab-${BESLAB_VERSION}.zip
	
        elif [ -z $BESLAB_VERSION ] || [ "$BESLAB_VERSION" == "dev" ];then

           [[ -d $unzip_location ]] && rm -rf $unzip_location
	   git clone "https://github.com/$BLIMAN_NAMESPACE/BeSLab" $unzip_location | __bliman_log     
	   export BESLAB_VERSION="0.0.0"
           #mkdir -p "$HOME/.besman/envs/0.0.0" | __bliman_log 
	   #cp "$unzip_location/src/*" "$HOME/.besman/envs/0.0.0" | __bliman_log
	   cp $unzip_location/src/* "$HOME/.besman/envs/" | __bliman_log
	fi

        if [ -f "$HOME/.bliman/etc/genesis_data.sh" ];then

           if grep -q "BESLAB_VERSION" "/root/.bliman/etc/genesis_data.sh"; then
              sed -i "/^export BESLAB_VERSION/c\export BESLAB_VERSION=\"$BESLAB_VERSION\"" "$HOME/.bliman/etc/genesis_data.sh"
	   else
              echo "export BESLAB_VERSION=\"$BESLAB_VERSION\"" >> "$HOME/.bliman/etc/genesis_data.sh"
	   fi
	fi

	source "$HOME/.besman/bin/besman-init.sh" 
        bes list | __bliman_log
}

function __bliman_install_beslab_env() {
	__bliman_echo_yellow "Called BesMan to install BeSLab."
	bes install -env src-env -V $BESLAB_VERSION
}

function __bliman_check_besman() {
	
	if [ -f "$HOME/.bashrc" ];then
	   source "$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ];then
	   source "$HOME/.zshrc"
	fi

	if [[ ! -d $BESMAN_DIR ]]; then
		__bliman_echo_red "BeSman not found. Execure \"bli initmode <modename> \" first. "
		return 1
	else
		__bliman_echo_white "BeSman found."
		return 0
	fi
}

function __bliman_prime_installer_playbook() {
	__bliman_echo_yellow "Priming installer playbook"
	local playbook roles
	playbook="$HOME/oah-bes-vm/provisioning/oah-install.yml"
	# requirements="$HOME/oah-bes-vm/provisioning/oah-requirements.yml"
	# roles=$(yq '.[].name' "$requirements" | sed 's/"//g')
	[[ -f "$playbook" ]] && rm "$playbook"
	touch "$playbook"
	cat <<EOF >>"$playbook"

---
- hosts: localhost
  vars:
  - oah_command: install

  vars_files:
    - ../oah-config.yml

  pre_tasks:
    - name: "printing debug msg"
#       become: yes
      debug:
        msg: In pre_tasks
    # Will need the shell provision to install python-minimal first
    - name: Install python3 and python3-pip for Ansible
      become: yes
      raw: test -e /usr/bin/python || (apt update && apt -y install python3.8 && apt install -y python3-pip)
    - include_tasks: tasks/init-debian.yml
      when: ansible_os_family == 'Debian'
  roles:
    - oah.beslab
EOF
}

function __bliman_generate_vm_roles() {
	local vm_path requirements_file roles_vars
	vm_path="$HOME/oah-bes-vm"
	requirements_file="$vm_path/provisioning/oah-requirements.yml"
	[[ -f "$requirements_file" ]] && rm "$requirements_file"
	touch "$requirements_file"
	__bliman_echo_yellow "Writing roles to requirements file"
	echo "---" >>"$requirements_file"

	{
		echo "- src: https://github.com/$BLIMAN_NAMESPACE/ansible-role-oah-beslab"
		echo "  version: main"
		echo "  name: oah.beslab"
	} >>"$requirements_file"

}

function __bliman_generate_vm_config() {
	local vm_path vm_config_file
	vm_path="$HOME/oah-bes-vm"
	vm_config_file="$vm_path/oah-config.yml"
	[[ -f "$vm_config_file" ]] && rm "$vm_config_file"
	touch "$vm_config_file"

	__bliman_echo_yellow "Writing config file"

	cat <<EOF >> "$vm_config_file"
---
# environment Name
oah_env_name: "$BESLAB_VM_NAME"
#GUI Flag
oah_vm_gui: "$BESLAB_GUI"
#vagrant_box: OAH/ubuntu1404
vagrant_box: "$BESLAB_VAGRANT_BOX"
vagrant_user: "$BESLAB_USER"
oah_env_user: "$BESLAB_USER"
oah_user: oahdev


# If you need to run multiple instances of Openhack VM, set a unique hostname,
# machine name, and IP address for each instance.
vagrant_hostname: $BESLAB_VM_NAME.dev
vagrant_machine_name: $BESLAB_VM_NAME
#vagrant_ip: 192.168.88.88
vagrant_ip: 0.0.0.0
# vagrant_ip: 192.168.63.254

# Allow OAH VM to be accessed via a public network interface on your host.
# Vagrant boxes are insecure by default, so be careful. You've been warned!
# See: https://docs.vagrantup.com/v2/networking/public_network.html
vagrant_public_ip: ""

# A list of synced folders, with the keys 'local_path', 'destination', 'id', and
# a 'type' of [nfs|rsync|smb] (leave empty for slow native shares).
vagrant_synced_folders: []
#   # The first synced folder will be used for the default Drupal installation, if
#   # build_makefile: is 'true'.
#   - local_path: ~/.oah/data
#     destination: /home/{{ oah_user }}/.oah/data
#     type: nfs
#     create: true

  # - local_path: ~/oah-sites/{{ vagrant_machine_name }}
  #   destination: /var/www/{{ vagrant_machine_name }}
  #   type: nfs
  #   create: true

# Memory and CPU to use for this VM.
vagrant_memory: 9000
vagrant_cpus: 1 

# # The web server software to use. Can be either 'apache' or 'nginx'.
# oahvm_webserver: apache

vagrant_plugins:
  - name: vagrant-vbguest
  - name: vagrant-hostsupdater
  - name: vagrant-auto_network

#

# Cron jobs are added to the root user's crontab. Keys include name (required),
# minute, hour, day, weekday, month, job (required), and state.
#oahvm_cron_jobs: []
  # - {
  #   name: "Drupal Cron",
  #   minute: "*/30",
  #   job: "drush -r {{ drupal_core_path }} core-cron"
  # }


# Apache VirtualHosts. Add one for each site you are running inside the VM. For
# multisite deployments, you can point multiple servernames at one documentroot.
# View the virtualenv.apache Ansible Role README for more options.
# apache_vhosts:
#
#
#   - servername: "adminer.{{ vagrant_machine_name }}.dev"
#     documentroot: "/opt/adminer"
#
#   - servername: "xhprof.{{ vagrant_machine_name }}.dev"
#     documentroot: "/usr/share/php/xhprof_html"
#
#   - servername: "pimpmylog.{{ vagrant_machine_name }}.dev"
#     documentroot: "/usr/share/php/pimpmylog"
#
# apache_remove_default_vhost: true
# apache_mods_enabled:
#   - expires.load
#   - ssl.load
#   - rewrite.load

# Nginx hosts. Each site will get a server entry using the configuration defined
# here. Set the 'is_php' property for document roots that contain PHP apps like
# Drupal.
# nginx_hosts:
#   - server_name: "adminer.{{ vagrant_machine_name }}.dev"
#     root: "/opt/adminer"
#     is_php: true
#
#   - server_name: "xhprof.{{ vagrant_machine_name }}.dev"
#     root: "/usr/share/php/xhprof_html"
#     is_php: true
#
#   - server_name: "pimpmylog.{{ vagrant_machine_name }}.dev"
#     root: "/usr/share/php/pimpmylog"
#     is_php: true
#
# nginx_remove_default_vhost: true


# Comment out any extra utilities you don't want to install. If you don't want
# to install *any* extras, make set this value to an empty set, e.g. [].
# installed_extras:
#   - adminer
#   - mailhog
#   - memcached
#   - nodejs
#   - pimpmylog
#   # - ruby
#   # - selenium
#   # - solr
#   - varnish
#   - xdebug
#   - xhprof

# Add any extra apt or yum packages you would like installed.
# extra_packages:
#   - unzip
#
# # nodejs must be in installed_extras for this to work.
# nodejs_version: "0.12"
# nodejs_npm_global_packages: []
#
# # ruby must be in installed_extras for this to work.
# ruby_install_gems: []
#
# # You can configure almost anything else on the server in the rest of this file.
# extra_security_enabled: false
#
#
# firewall_allowed_tcp_ports:
#   - "22"
#   - "25"
#   - "80"
#   - "81"
#   - "443"
#   - "4444"
#   - "8025"
#   - "8080"
#   - "8443"
#   - "8983"
#   - "4200"
#
# firewall_log_dropped_packets: false
#
# # PHP Configuration. Currently-supported versions: 5.5, 5.6, 7.0 (experimental).
# php_version: "5.6"
# php_memory_limit: "192M"
# php_display_errors: "On"
# php_display_startup_errors: "On"
# php_enable_php_fpm: 1
# php_realpath_cache_size: "1024K"
# php_sendmail_path: "/usr/sbin/ssmtp -t"
# php_opcache_enabled_in_ini: true
# php_opcache_memory_consumption: "192"
# php_opcache_max_accelerated_files: 4096
# php_max_input_vars: "4000"
#
# composer_path: /usr/bin/composer
# composer_home_path: '/home/{{ oah_user }}/.composer'
# # composer_global_packages:
# #   - { name: phpunit/phpunit, release: '@stable' }
#
# # MySQL Configuration.
# mysql_root_password: root
# mysql_slow_query_log_enabled: true
# mysql_slow_query_time: 2
# mysql_wait_timeout: 300
# adminer_install_filename: index.php
#
# # Varnish Configuration.
# varnish_listen_port: "81"
# varnish_default_vcl_template_path: templates/oahvm.vcl.j2
# varnish_default_backend_host: "127.0.0.1"
# varnish_default_backend_port: "80"
#
# # Pimp my Log settings.
# pimpmylog_install_dir: /usr/share/php/pimpmylog
# pimpmylog_grant_all_privs: true
#
# # XDebug configuration. XDebug is disabled by default for better performance.
# php_xdebug_default_enable: 0
# php_xdebug_coverage_enable: 0
# php_xdebug_cli_enable: 1
# php_xdebug_remote_enable: 1
# php_xdebug_remote_connect_back: 1
# # Use PHPSTORM for PHPStorm, sublime.xdebug for Sublime Text.
# php_xdebug_idekey: sublime.xdebug
# php_xdebug_max_nesting_level: 256
#
# # Solr Configuration (if enabled above).
# solr_version: "4.10.4"
# solr_xms: "64M"
# solr_xmx: "128M"
#
# # Selenium configuration.
# selenium_version: 2.46.0
#
# # Other configuration.
# known_hosts_path: ~/.ssh/known_hosts
EOF
	while read -r line; do
		[[ "$line" == "---" ]] && continue
		if echo "$line" | grep -qe "^#" || echo "$line" | grep -qe "^BESLAB_" || echo "$line" | grep -qe "^-"; then
			continue
		fi
		# if echo "$line" | grep -qe "^BESLAB_"
		# then
		#     continue
		# fi
		echo "$line" >>"$vm_config_file"
	done <"$BLIMAN_GENSIS_FILE_PATH"

}
