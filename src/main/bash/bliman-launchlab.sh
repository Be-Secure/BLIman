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
            __bliman_echo_red "Lab mode is not set to \"lite\" mode. Execute \"bli initmode lite\" first and try again!!"
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
    
    __bliman_echo_white "BLIman is going to install following lab components as configured in genesis file."
    __bliman_echo_yellow "==================================================================================================="
    __bliman_echo_yellow "                                BESLAB TYPE = $BESLAB_LAB_TYPE"
    __bliman_echo_yellow "                                BESLAB MODE = $BESLAB_LAB_MODE"
    __bliman_echo_yellow "                                BESLAB NAME = $BESMAN_LAB_NAME"
    __bliman_echo_yellow "                                BESLAB VERSION = $BESLAB_VERSION"
    __bliman_echo_yellow "                                BESMAN VERSION = $BESMAN_VER"
    __bliman_echo_yellow "==================================================================================================="
    __bliman_echo_yellow ""

    if [ $BESLAB_LAB_TYPE == "private" ] && ([ $BESLAB_LAB_MODE == "lite" ] || [ $BESLAB_LAB_MODE == "bare" ]);then
      __bliman_echo_yellow "==================================================================================================="
      __bliman_echo_yellow "                  CODE COLLABORATION TOOL = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL"
      __bliman_echo_yellow "                  CODE COLLABORATION TOOL VERSION = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL_VERSION"
      __bliman_echo_yellow "                  DASHBOARD TOOL = $BESLAB_DASHBOARD_TOOL"
      __bliman_echo_yellow "                  DASHBOARD TOOL VERSION = $BESLAB_DASHBOARD_RELEASE_VERSION"
      __bliman_echo_yellow "==================================================================================================="
    fi

    if [[ "$BESLAB_LAB_MODE" == "host" ]]; then
        __bliman_launch_host_mode
    elif [[ "$BESLAB_LAB_MODE" == "bare" ]]; then
        __bliman_launch_bare_mode
    elif [[ "$BESLAB_LAB_MODE" == "lite" ]]; then
        __bliman_launch_lite_mode
    fi
    if [ ! -z $1 ];then
       if [ $1 == "OASP" ];then
          serviceprovider="OASP"
       elif [ $1 == "OSPO" ];then
          serviceprovider="OSPO"
       elif [ $1 == "AIC" ];then
          serviceprovider="AIC"
       else
          serviceprovider="default"
       fi

    fi

    #__bliman_echo_green ""
    #__bliman_echo_white "BLIman installed following lab components to the system."
    #__bliman_echo_green "==================================================================================================="
    #__bliman_echo_green "                                BESLAB TYPE = $BESLAB_LAB_TYPE"
    #__bliman_echo_green "                                BESLAB MODE = $BESLAB_LAB_MODE"
    #__bliman_echo_green "                                BESLAB NAME = $BESMAN_LAB_NAME"
    #__bliman_echo_green "                                BESLAB VERSION = $BESLAB_VERSION"
    #__bliman_echo_green "                                BESMAN VERSION = $BESMAN_VER"
    #__bliman_echo_green "==================================================================================================="
    #__bliman_echo_green ""

    if [ $BESLAB_LAB_TYPE == "private" ] && ([ $BESLAB_LAB_MODE == "lite" ] || [ $BESLAB_LAB_MODE == "bare" ]);then
      pubip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
      __bliman_echo_green ""

      if [ ! -z $BESLAB_DOMAIN_NAME ];then
         domainURL="http://$BESLAB_DOMAIN_NAME"
      else
         myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
         domainURL="http://$myip"
      fi

      if [ ! -z ${BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL_PORT} ];then
        gitlab_url="$domainURL:${BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL_PORT}"
      else
        gitlab_url="$domainURL:8081"
      fi
      response_code_gitlab=$(curl -sL -w "%{http_code}\\n" "$gitlab_url" -o /dev/null)

      if [ ! -z ${BESLAB_DASHBOARD_PORT} ];then
        besl_url="$domainURL:${BESLAB_DASHBOARD_PORT}"
      else
        besl_url="$domainURL"
      fi
      response_code_besl=$(curl -sL -w "%{http_code}\\n" "$besl_url" -o /dev/null)

      __bliman_echo_green "==================================================================================================="
      if [ $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL == "gitlab-ce" ] && [ "$response_code_gitlab" == "200" ];then
        __bliman_echo_green "                   CODE COLLABORATION TOOL = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL"
        __bliman_echo_green "                   CODE COLLABORATION TOOL VERSION = $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL_VERSION"
      fi
      if [ $BESLAB_DASHBOARD_TOOL == "BeSLighthouse" ] && [ "$response_code_besl" == "200" ];then
        __bliman_echo_green "                   DASHBOARD TOOL = $BESLAB_DASHBOARD_TOOL"
        __bliman_echo_green "                   DASHBOARD TOOL VERSION = $BESLAB_DASHBOARD_RELEASE_VERSION"
      fi
      __bliman_echo_green "==================================================================================================="
      __bliman_echo_green ""


      if [ $BESLAB_PRIVATE_LAB_CODECOLLAB_TOOL == "gitlab-ce" ] && [ "$response_code_gitlab" == "200" ];then
	 __bliman_echo_white " "
	 __bliman_echo_white "==================================================================================================="
         __bliman_echo_white "   Gitlab is accessible at $gitlab_url "
	 __bliman_echo_white "        Login to the gitlab using username as $BESMAN_LAB_NAME and default password."
	 __bliman_echo_white "==================================================================================================="
	 __bliman_echo_white " "
      fi

      if [ $BESLAB_DASHBOARD_TOOL == "BeSLighthouse" ] && [ "$response_code_besl" == "200" ];then
          __bliman_echo_white " "
	   __bliman_echo_white "==================================================================================================="
          __bliman_echo_white "                            BeSLighthouse UI is accessible at $besl_url"
	   __bliman_echo_white "==================================================================================================="
          __bliman_echo_white " "
      fi
      __bliman_echo_white " "
    fi
}


