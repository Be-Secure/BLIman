#!/bin/bash

[[ -f "$HOME/.bliman/src/bliman-utils.sh" ]] && source "$HOME/.bliman/src/bliman-utils.sh"

echo ' ########  ########  ######  ##          ###    ########   '
echo ' ##     ## ##       ##    ## ##         ## ##   ##     ##  '
echo ' ##     ## ##       ##       ##        ##   ##  ##     ##  '
echo ' ########  ######    ######  ##       ##     ## ########   '
echo ' ##     ## ##             ## ##       ######### ##     ##  '
echo ' ##     ## ##       ##    ## ##       ##     ## ##     ##  '
echo ' ########  ########  ######  ######## ##     ## ########   '
echo ''
echo ' ##       #### ########  ########  '
echo ' ##        ##     ##     ##        '
echo ' ##        ##     ##     ##        '
echo ' ##        ##     ##     ######    '
echo ' ##        ##     ##     ##        '
echo ' ##        ##     ##     ##        '
echo ' ######## ####    ##     ########  '
echo ''
echo ' ##     ##  #######  ########  ########  '
echo ' ###   ### ##     ## ##     ## ##        '
echo ' #### #### ##     ## ##     ## ##        '
echo ' ## ### ## ##     ## ##     ## ######    '
echo ' ##     ## ##     ## ##     ## ##        '
echo ' ##     ## ##     ## ##     ## ##        '
echo ' ##     ##  #######  ########  ########  '
echo ''

local tmp_location="/tmp"

if [[ ! -d $HOME/.besman ]]; then
        if [  ! -z ${BESMAN_DEV} ] && [ ${BESMAN_DEV} == "true" ];then
	  prd=`pwd`
          cd /opt/
	  git clone --quiet https://github.com/Be-Secure/BeSman.git
          cd BeSman
	  source quick_install.sh
          rm -rf /opt/BeSman
          cd $prd
        else

           if [ ! -z ${BESMAN_VER} ];then
	      __bliman_echo_yellow "Installing BeSMan version ${BESMAN_VER}"	   
        curl --silent -o $tmp_location/besman-${BESMAN_VER}.zip --fail --location --progress-bar "https://github.com/Be-Secure/BeSMan/archive/refs/tags/${BESMAN_VER}.zip"
        unzip -qd $tmp_location/  $tmp_location/besman-${BESMAN_VER}.zip
	      current_wd=`pwd`
	      cd $tmp_location/BeSman-${BESMAN_VER} 
	      chmod +x quick_install.sh
	      source quick_install.sh --force
              cd $current_wd
	      [[ -f ${BESMAN_DIR}/var/version.txt ]] && echo "${BESMAN_VER}" > "${BESMAN_DIR}/var/version.txt"
              besman_user_config_file="${BESMAN_DIR}/etc/user-config.cfg"
              sed -i "/BESMAN_VERSION=/c\BESMAN_VERSION=${BESMAN_VER}" $besman_user_config_file
 
              __bliman_echo_green "#####################################################################################"
              __bliman_echo_green "                  Installed BeSMan version ${BESMAN_VER} successfully."
              __bliman_echo_green "#####################################################################################"
	   else
               response=$(curl -s "https://api.github.com/repos/Be-Secure/BeSMan/releases/latest")

              if [[ $response == *"message"*"Not Found"* ]];then
                 __bliman_echo_red "BeSMan release version is not found."
                 __bliman_echo_red "Exiting..."
                 return 1
              else
                 besver=$(echo "$response" | jq -r '.tag_name')
              fi
	      __bliman_echo_yellow "Installing BeSMan version ${besver}"
              export BESMAN_VER=$besver
	      curl --silent -o $tmp_location/besman-${besver}.zip --fail --location --progress-bar "https://github.com/Be-Secure/BeSMan/archive/refs/tags/${besver}.zip"
              [[ -d $tmp_location/besman-${besver} ]] && rm -rf $tmp_location/besman-${besver}
	      unzip -qd $tmp_location/  $tmp_location/besman-${besver}.zip
              current_wd=`pwd`
              cd $tmp_location/BeSman-${besver}/
              chmod +x quick_install.sh
              source quick_install.sh --force
              cd $current_wd
	      [[ -f ${BESMAN_DIR}/var/version.txt ]] && echo "${besver}" > "${BESMAN_DIR}/var/version.txt"
	      besman_user_config_file="${BESMAN_DIR}/etc/user-config.cfg"
	      sed -i "/BESMAN_VERSION=/c\BESMAN_VERSION=${besver}" $besman_user_config_file
              __bliman_echo_green "#####################################################################################"
	      __bliman_echo_green "                  Installed BeSMan version ${besver} successfully."
	      __bliman_echo_green "#####################################################################################"
           fi
        fi
	if [  -f "$HOME/.besman/bin/besman-init.sh" ];then
	   source "$HOME/.besman/bin/besman-init.sh" 2>&1 | __bliman_log
	else
           __bliman_echo_red "besman-init.sh not found. BeSMan not installed correctly. Exiting ..."
	   return 1
        fi
else
	__bliman_echo_yellow "BeSman already installed."
fi

