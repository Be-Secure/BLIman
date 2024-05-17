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

tmp_location="/tmp"
BLIMAN_LOG_FILE=$HOME/.bliman/log/bliman_log
[[ ! -f $BLIMAN_LOG_FILE ]] && touch $BLIMAN_LOG_FILE

if [[ ! -d $HOME/.besman ]]; then
        if [  ! -z ${BESMAN_DEV} ] && [ ${BESMAN_DEV} == "true" ];then
	  prd=`pwd`
          cd /opt/
	  git clone --quiet https://github.com/Be-Secure/BeSman.git 2>&1>>$BLIMAN_LOG_FILE
          cd BeSman
	  source quick_install.sh 2>&1>$BLIMAN_LOG_FILE
          rm -rf /opt/BeSman
          cd $prd
        else

           if [ ! -z ${BESMAN_VER} ];then
              besver=${BESMAN_VER}
           else
              response=$(curl --silent "https://api.github.com/repos/Be-Secure/BeSMan/releases/latest")

              if [[ $response == *"message"*"Not Found"* ]];then
                 __bliman_echo_red "BeSMan release version is not found."
                 __bliman_echo_red "Exiting..."
                 return 1
              else
                 besver=$(echo "$response" | jq -r '.tag_name')
              fi 
	   fi
           __bliman_echo_yellow "Installing BeSMan version ${besver}"
           export BESMAN_VER=$besver
           curl --silent -o $tmp_location/besman-${besver}.zip --fail --location --progress-bar "https://github.com/Be-Secure/BeSMan/archive/refs/tags/${besver}.zip" 2>&1>>$BLIMAN_LOG_FILE

           which unzip 2>&1>>$BLIMAN_LOG_FILE

	   if [ xx"$?" != xx"0" ];then
              __bliman_echo_yellow "Installing unzip..."
	      apt-get install unzip -y 2>&1>>$BLIMAN_LOG_FILE
           fi
	   unzip -qd $tmp_location/  $tmp_location/besman-${besver}.zip 2>&1>>$BLIMAN_LOG_FILE
           current_wd=`pwd`
           cd $tmp_location/BeSman-${besver}
           chmod +x quick_install.sh
           source quick_install.sh --force 2>&1>>$BLIMAN_LOG_FILE
           cd $current_wd
           [[ -f ${BESMAN_DIR}/var/version.txt ]] && echo "${besver}" > "${BESMAN_DIR}/var/version.txt"
           besman_user_config_file="${BESMAN_DIR}/etc/user-config.cfg"
           sed -i "/BESMAN_VERSION=/c\BESMAN_VERSION=${besver}" $besman_user_config_file 2>&1>>$BLIMAN_LOG_FILE
        fi

	if [ -f "$HOME/.besman/bin/besman-init.sh" ];then
                __bliman_echo_green "#####################################################################################"
                __bliman_echo_green "                  Installed BeSMan version ${BESMAN_VER} successfully."
                __bliman_echo_green "#####################################################################################"
        else
                #__bliman_echo_red "#####################################################################################"
                __bliman_echo_red " >>>>>>>>>> BeSMan version ${BESMAN_VER} NOT installed properly."
                #__bliman_echo_red " >>>>>>>>>> BeSMan version ${BESMAN_VER} NOT installed properly."
                #__bliman_echo_red "#####################################################################################"
		return 1
        fi

	if [  -f "$HOME/.besman/bin/besman-init.sh" ];then
	   source "$HOME/.besman/bin/besman-init.sh" 2>&1>$BLIMAN_LOG_FILE
	else
           __bliman_echo_red "besman-init.sh not found. BeSMan not installed correctly. Exiting ..."
	   return 1
        fi
else
	__bliman_echo_yellow "BeSman already installed."
fi

