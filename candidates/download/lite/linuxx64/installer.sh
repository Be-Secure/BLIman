#!/bin/bash
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
	  git clone https://github.com/Be-Secure/BeSman.git 2>&1 | __bliman_log
          cd BeSman
	  source quick_install.sh 2>&1 | __bliman_log
          rm -rf /opt/BeSman 2>&1 | __bliman_log
          cd $prd
        else

           if [ ! -z ${BESMAN_VER} ];then
	      __bliman_echo_yellow "Installing BeSMan version ${BESMAN_VER}"	   
              curl -o $tmp_location/besman-${BESMAN_VER}.zip --fail --location --progress-bar "https://github.com/Be-Secure/BeSMan/archive/refs/tags/${BESMAN_VER}.zip"
              unzip -qo $tmp_location/  $tmp_location/besman-${BESMAN_VER}.zip 2>&1 | __bliman_log
	      current_wd=`pwd`
	      cd $tmp_location/BeSMan-${BESMAN_VER} 
	      chmod +x quick_install.sh
	      source quick_install.sh 2>&1 | __bliman_log
              cd $current_wd
	      [[ -f ${BESMAN_DIR}/var/version.txt ]] && echo "${BESMAN_VER}" > "${BESMAN_DIR}/var/version.txt"
              besman_user_config_file="${BESMAN_DIR}/etc/user-config.cfg"
              sed -i "/BESMAN_VERSION=/c\BESMAN_VERSION=${BESMAN_DIR}" $besman_user_config_file 2>&1 | __bliman_log
 
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
	      curl -o $tmp_location/besman-${besver}.zip --fail --location --progress-bar "https://github.com/Be-Secure/BeSMan/archive/refs/tags/${besver}.zip"
              unzip -qo $tmp_location/  $tmp_location/besman-${besver}.zip
              current_wd=`pwd`
              cd $tmp_location/BeSMan-${besver}
              chmod +x quick_install.sh
              source quick_install.sh 2>&1 | __bliman_log
              cd $current_wd
	      [[ -f ${BESMAN_DIR}/var/version.txt ]] && echo "${besver}" > "${BESMAN_DIR}/var/version.txt"
	      besman_user_config_file="${BESMAN_DIR}/etc/user-config.cfg"
	      sed -i "/BESMAN_VERSION=/c\BESMAN_VERSION=${besver}" $besman_user_config_file 2>&1 | __bliman_log
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

