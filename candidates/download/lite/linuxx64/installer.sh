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
if [[ ! -d $HOME/.besman ]]; then
	echo "Installing BeSman"
        echo "IS Release = $BLIMAN_IS_REL"
        if [  ! -z ${BLIMAN_IS_REL} ] && [ ${BLIMAN_IS_REL} == "false" ];then
	  prd=`pwd`
          cd /opt/
	  git clone https://github.com/Be-Secure/BeSman.git | __bliman_log
          cd BeSman
	  ./quick_install.sh | __bliman_log
          rm -rf /opt/BeSman | __bliman_log
          cd $prd
          #curl -L "https://raw.githubusercontent.com/Be-Secure/BeSman/master/quick_install.sh" | bash 
        else
	   curl -L "https://raw.githubusercontent.com/Be-Secure/BeSman/dist/dist/get.besman.io" | bash
        fi
	if [  -f "$HOME/.besman/bin/besman-init.sh" ];then
	   source "$HOME/.besman/bin/besman-init.sh"
	else
           echo "besman-init.sh not found. BeSMan not installed correctly. Exiting ..."
	   return 1
        fi
else
	echo "BeSman found"
fi

