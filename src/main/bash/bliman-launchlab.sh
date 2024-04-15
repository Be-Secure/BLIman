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

function __bli_launchlab()
{
    if [ -z $BESMAN_LAB_TYPE ] || [ -z $BESMAN_LAB_NAME ];then
       if [ ! -z $BLIMAN_DIR ];then
         beslabConfig="$BLIMAN_DIR/etc/genesis_data.sh"
	 currmode=`cat $BLIMAN_DIR/candidates/current/mode`
	 if [ $currmode != "lite" ];then
            __bliman_echo_yellow ""
            __bliman_echo_red "Lab mode is not set to \"lite\". Execute \"bli initmode lite\" first and try again!!"
            __bliman_echo_red "Exiting ..."
            __bliman_echo_yellow ""
	    return 1
         fi
       else
          beslabConfig="$HOME/.bliman/etc/genesis_data.sh"
       fi

       if [ -f $beslabConfig ];then
          source $beslabConfig
       else
          __bliman_echo_yellow ""
          __bliman_echo_red "Lab configuration not found. Execute \"bli load\" with the genesis file first and try again!!"
	  __bliman_echo_red "Exiting ..."
	  __bliman_echo_yellow ""
	  return 1
       fi
    fi
    
    __bliman_echo_white "BLIMAN is going to install following lab components as configured in genesis file."
    __bliman_echo_yellow "    LAB TYPE = $BESLAB_LAB_TYPE"
    __bliman_echo_yellow "    LAB MODE = $BESLAB_LAB_MODE"
    __bliman_echo_yellow "    LAB NAME = $BESMAN_LAB_NAME"

    if [ $BESLAB_LAB_TYPE == "private" ] && ([ $BESLAB_LAB_MODE == "lite" ] || [ $BESLAB_LAB_MODE == "bare" ]);then
      __bliman_echo_yellow "    CODE COLLABORATION TOOL = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL"
      __bliman_echo_yellow "    CODE COLLABORATION TOOL VERSION = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL_VERSION"
      __bliman_echo_yellow "    CODE COLLABORATION DATASTORES = $BESLAB_CODECOLLAB_DATASTORES"
      __bliman_echo_yellow "    DASHBOARD TOOL = $BESLAB_DASHBOARD_TOOL"
      __bliman_echo_yellow "    DASHBOARD TOOL VERSION = $BESLAB_DASHBOARD_RELEASE_VERSION"
    fi

    if [[ "$BLIMAN_LAB_MODE" == "host" ]]; then
        __bliman_echo_white "Installing beslab in host mode"
        __bliman_launch_host_mode
	__bliman_echo_green "Installed beslab in host mode"
    elif [[ "$BLIMAN_LAB_MODE" == "bare" ]]; then
        __bliman_echo_white "Installing beslab in bare mode"
        __bliman_launch_bare_mode
	__bliman_echo_green "Installed beslab in bare mode"
    elif [[ "$BLIMAN_LAB_MODE" == "lite" ]]; then
        __bliman_echo_white "Installing beslab in lite mode"
        __bliman_launch_lite_mode
	__bliman_echo_green "Installed beslab in lite mode"
    fi
    
    __bliman_echo_green ""
    __bliman_echo_yellow "BLIMAN installed following lab components to the system."
    __bliman_echo_green "    LAB TYPE = $BESLAB_LAB_TYPE"
    __bliman_echo_green "    LAB MODE = $BESLAB_LAB_MODE"
    __bliman_echo_green "    LAB NAME = $BESMAN_LAB_NAME"
    __bliman_echo_green ""

    if [ $BESLAB_LAB_TYPE == "private" ] && ([ $BESLAB_LAB_MODE == "lite" ] || [ $BESLAB_LAB_MODE == "bare" ]);then
      __bliman_echo_green "    CODE COLLABORATION TOOL = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL"
      __bliman_echo_green "    CODE COLLABORATION TOOL VERSION = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL_VERSION"
      __bliman_echo_green "    CODE COLLABORATION DATASTORES = $BESLAB_CODECOLLAB_DATASTORES"
      __bliman_echo_green "    DASHBOARD TOOL = $BESLAB_DASHBOARD_TOOL"
      __bliman_echo_green "    DASHBOARD TOOL VERSION = $BESLAB_DASHBOARD_RELEASE_VERSION"
      __bliman_echo_green ""

      pubip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
      __bliman_echo_green ""

      if [ $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL == "gitlab-ce" ];then
	  __bliman_echo_white " "
         __bliman_echo_white "Gitlab is accessible at $pubip "
	 __bliman_echo_white "    Login to the gitlab using username as $BESMAN_LAB_NAME. Use default password."
	  __bliman_echo_white " "
      fi

      if [ $BESLAB_DASHBOARD_TOOL == "beslighthouse" ];then
          __bliman_echo_white " "
          __bliman_echo_white "BeSLighthouse is accessible at $pubip:3000 "
          __bliman_echo_white " "
      fi
      __bliman_echo_white " "
    fi
}


