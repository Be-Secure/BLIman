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
function install_toolname() {
    # Function to install the specific tool with the toolname.

    # check if the tool installation is enabled in genesis file
    # by checking INSTALL_TOOLNAME variable

    # Check if the specific version if tool is defined in genesis file by
    # checking TOOLNAME_VERSION variable.
    # If not defined any specific version install the latest available tool

    # To install the tool first check if there is an existing environment available for the tool
    # using besman command 'bes list env' and grep for the toolname to be istalled.
    # if no environment is found then look for the beslab function with a nameing 
    # convention like __besman_install_<toolname>.
    # if no environment and no function is found for the tool log Error and return
    # Do NOT write the tool installation steps in this file else create 
    # a besman environment ( follow the instruction at 
    #   https://github.com/Be-Secure/besecure-ce-env-repo/blob/master/CONTRIBUTING.md)
    # OR 
    # beslab a module. (Follow the instruction https://github.com/Be-Secure/BeSLab/blob/master/CONTRIBUTING.md) function instread.

    # Configure the tool as per required.

    # use comments to describe the function, its usage and parameters.

    # Add this function for each tool to be installed and call them in below function.
  
    
    echo ""
    return 0
}

function __bliman_launch_CUSTOMLABNAME() {
     
    # Call the functions written for each tool to be installed.
    install_toolnbame
    
    echo ""
    return 0
}