#!/bin/bash

function __bli_launch()
{
    local genesis_file_name genesis_file_url default_genesis_file_path
    genesis_file_name="beslab_genesis.yaml"
    genesis_file_url="$BLIMAN_LAB_URL/$genesis_file_name"
    
    [[ -z $BLIMAN_LAB_MODE ]] && __bliman_echo_red "Stop!!! Please run the install command first" && return 1
    if [[ -f "$HOME/$genesis_file_name" ]]; then

        __bliman_echo_yellow "Genesis file found at $HOME"
        export BLIMAN_GENSIS_FILE_PATH="$HOME/$genesis_file_name"
    else
        export BLIMAN_GENSIS_FILE_PATH="$BLIMAN_DIR/tmp/$genesis_file_name"
        __bliman_check_genesis_file_available "$genesis_file_url" || return 1
        __bliman_get_genesis_file "$genesis_file_url" "$BLIMAN_GENSIS_FILE_PATH"
    fi
    __bliman_load_export_vars "$BLIMAN_GENSIS_FILE_PATH"
    __bliman_generate_vm_roles
    __bliman_generate_vm_config

}


function __bliman_check_genesis_file_available()
{
    local url response
    url=$1
    response=$(curl --head --silent "$url" | head -n 1 | awk '{print $2}')
    if [ "$response" -eq 200 ]; then
        __bliman_echo_yellow "Genesis file found"
    else
        __bliman_echo_red "Could not find genesis file @ $url"
        return 1
    fi

}

function __bliman_get_genesis_file()
{
    local url default_genesis_file_path
    url=$1
    default_genesis_file_path=$2
    touch "$default_genesis_file_path"
    __bliman_secure_curl "$url" >> "$default_genesis_file_path"
    
}

function __bliman_check_for_yq()
{
    if [[ -z $(which yq) ]]; then
        __bliman_echo_yellow "Installing yq"
        python3 -m pip install yq
    else
        return
    fi
}

function __bliman_load_export_vars()
{
    local var value genesis_file_path tmp_file
    __bliman_check_for_yq 
    genesis_file_path=$1
    genesis_data=$(<"$genesis_file_path")
    tmp_file="$BLIMAN_DIR/tmp/source.sh"
    touch "$tmp_file"
    echo "#!/bin/bash" >> "$tmp_file"
    while read -r line 
    do
        [[ $line == "---" ]] && continue
        if echo "$line" | grep -qe "^BESLAB_"  
        then
            var=$(echo "$line" | cut -d ":" -f 1)
            value=$(yq ."$var" "$genesis_file_path" | sed 's/\[//; s/\]//; s/"//g' | tr -d '\n' | sed 's/ //g')
            unset "$var"
            echo "export $var=$value" >> "$tmp_file"
        fi
    done <<< "$genesis_data"
    source "$tmp_file"
    
}

function __bliman_generate_vm_roles()
{
    local vm_path requirements_file roles_vars
    vm_path="$HOME/oah-bes-vm"
    requirements_file="$vm_path/provisioning/oah-requirements.yml"
    [[ -f "$requirements_file" ]] && rm "$requirements_file"
    touch "$requirements_file"
    __bliman_echo_yellow "Writing roles to requirements file"
    echo "---" >> "$requirements_file"
    roles_vars=$(env | grep '^BESLAB_.*_ROLES' | cut -d "=" -f 1)
    for var in $roles_vars
    do
        roles=$(eval echo "\$$var" | sed "s/,/ /g")
        for role in $roles
        do
            {
                echo "- src: https://github.com/Be-Secure/ansible-role-oah-$role" 
                echo "  version: main"
                echo "  name: oah.$role"
            } >> "$requirements_file"
        done
    done    


}

function __bliman_generate_vm_config()
{
    local vm_path vm_config_file
    vm_path="$HOME/oah-bes-vm"
    vm_config_file="$vm_path/oah-config.yml"
    [[ -f "$vm_config_file" ]] && rm "$vm_config_file"
    touch "$vm_config_file"

    __bliman_echo_yellow "Writing config file"

    echo "---" >> "$vm_config_file"
    cat << EOF >> "$vm_config_file"
# environment Name
oah_env_name: "$BESLAB_VM_NAME"
#GUI Flag
oah_vm_gui: "$BESLAB_VM_GUI"
#vagrant_box: OAH/ubuntu1404
vagrant_box: "$BESLAB_VAGRANT_BOX"
vagrant_user: "$BESLAB_VM_USER"
oah_env_user: "$BESLAB_VM_USER"
oah_user: oahdev


# If you need to run multiple instances of Openhack VM, set a unique hostname,
# machine name, and IP address for each instance.
vagrant_hostname: oah-bes-vm.dev
vagrant_machine_name: oah-bes-vm
#vagrant_ip: 192.168.88.88
vagrant_ip: 0.0.0.0
# vagrant_ip: 192.168.63.254

# Allow OAH VM to be accessed via a public network interface on your host.
# Vagrant boxes are insecure by default, so be careful. You've been warned!
# See: https://docs.vagrantup.com/v2/networking/public_network.html
vagrant_public_ip: ""

# A list of synced folders, with the keys 'local_path', 'destination', 'id', and
# a 'type' of [nfs|rsync|smb] (leave empty for slow native shares).
#vagrant_synced_folders: []
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
while read -r line 
do
    [[ "$line" == "---" ]] && continue
    if echo "$line" | grep -qe "^#" || echo "$line" | grep -qe "^BESLAB_"  || echo "$line" | grep -qe "^-"
    then
        continue
    fi
    # if echo "$line" | grep -qe "^BESLAB_" 
    # then
    #     continue
    # fi
    echo "$line" >> "$vm_config_file"
done < "$BLIMAN_GENSIS_FILE_PATH"

}

