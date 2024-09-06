#!/usr/bin/env bash

function __bli_help {    
__bliman_echo_no_colour '  '
__bliman_echo_white 'NAME'
__bliman_echo_no_colour '   bli - The cli for BeSLab                                                                            '
__bliman_echo_no_colour '  '
__bliman_echo_white 'SYNOPSIS  '
__bliman_echo_no_colour '   bli [command] [options]                                                                             '
__bliman_echo_no_colour '  '
__bliman_echo_white 'DESCRIPTION'
__bliman_echo_no_colour '   BLIman (pronounced as ‘B-L-I-man’) is a command-line utility designed for creating and provisioning ' 
__bliman_echo_no_colour '   the BeSLab in Host/Bare/lite mode.  It helps security professionals to reduce the turn around time  '
__bliman_echo_no_colour '   for assessment of Open Source projects, AI Models, Model Datasets leaving them focus on the assess- '
__bliman_echo_no_colour '   ment task rather than setting up environment for it. BLIman also provides seamless support for the  '
__bliman_echo_no_colour '   installation of tools and utilities needed for the security professional for assessing different OSS' 
__bliman_echo_no_colour '   projects, AI models, Training datasets, documents and attest and publish the assement reports.      '
__bliman_echo_no_colour '  '
__bliman_echo_white ' COMMANDS '
__bliman_echo_no_colour '   help: Display the help command                                                                      '
__bliman_echo_no_colour '   list: List available modes for the Lab installation.                                                '
__bliman_echo_no_colour '   initmode <modename>: Initializes the lab installation mode.                                                    '
__bliman_echo_cyan      '     Available modes are:                                                                              '
    __bliman_echo_cyan  '       host - This mode installs lab on a virtual machine.                                             '
    __bliman_echo_cyan  '       bare - In this mode lab is installed on local or remote machine using ansible roles.            '
    __bliman_echo_cyan  '       lite - Lite mode is the lightweight mode and installs the lab using only shell scripts.         '
__bliman_echo_no_colour '   load: Read and load th Genesis file.                                                                '
__bliman_echo_no_colour '   launchlab: install the lab components.                                                              '
__bliman_echo_no_colour '   status: Display the list of installed Lab, its mode and tools with the versions installed           '
__bliman_echo_no_colour '   create: create user/project for the lab.                                                            '
__bliman_echo_no_colour '  '
__bliman_echo_white ' OPTIONS '
__bliman_echo_no_colour '   --force: To update forcefully                                                                       '
__bliman_echo_no_colour '   --version: BLIman version to be installed.                                                          '
__bliman_echo_no_colour '  '
__bliman_echo_white 'EXAMPLE'
__bliman_echo_no_colour '  $ bli help                                                                                           '
__bliman_echo_no_colour '  '
__bliman_echo_white 'For details about specific command execute                                                                 '
__bliman_echo_yellow    '   $ bli help <command name>                                                                           '
__bliman_echo_no_colour '   Choose command name from list of COMMANDS above'
__bliman_echo_no_colour '  '
}

function __bli_help_create {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   create - To create users/projects for code collaborator tool.                                   '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '   $ bli create                                                                                       '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   The bli create command does create the user and projects for the code collaborator tool. It     '
    __bliman_echo_no_colour '   helps the lab admin to provision the lab once installed. Create command can accept the parame-  '
    __bliman_echo_no_colour '   ters for the user creation via command line and also by can read a file containing user or      '
    __bliman_echo_no_colour '   project list in a ":" seprated parameters list.                                                 '
    __bliman_echo_no_colour '  '
    __bliman_echo_white ' OPTIONS '
    __bliman_echo_no_colour '   --file: To read the users or projects from the file specified. The users and projects should be '
    __bliman_echo_no_colour '           Listed with ":" seprated values and each line should contain one user/project paramerters'
    __bliman_echo_white '       USER OPTIONS '
    __bliman_echo_no_colour '       --lab: lab is gitlab or github                                                              '
    __bliman_echo_no_colour '       --firstname: First name of the user to create                                               '
    __bliman_echo_no_colour '       --lastname: Last name of the user to create                                                 '
    __bliman_echo_no_colour '       --username: Username for the login                                                          '
    __bliman_echo_no_colour '       --useremail: Email for the user to create                                                   '
    __bliman_echo_no_colour '       --isadmin: Set it true if the new user is to give admin rights.                             '
    __bliman_echo_no_colour '       --isexternal: Set to true if the user should not see the internal projects and users.       '
    __bliman_echo_no_colour '       --isprivate: Set it true if the user profile is not visible to other users. By default true '
    __bliman_echo_no_colour '       --file: Path to the file to parse the user details from a file instead of above command line'
    __bliman_echo_no_colour '               options. Format of file should be as below.                                         '
    __bliman_echo_no_colour '       <gitlab|github>:<user first name>:<user last name>:<username>:<email>:<isadmin>:<isexternal>:<isprivate>'
    __bliman_echo_no_colour '       replace with the values and remove < and > from each field.'
    __bliman_echo_no_colour '  '
    __bliman_echo_white '       PROJECT OPTIONS '
    __bliman_echo_no_colour '       --lab: lab is gitlab or github                                                              '
    __bliman_echo_no_colour '       --usertoken: Access token of the user creating project (mandatory parameter for --file as well.'
    __bliman_echo_no_colour '       --projectname: Name of the project to be created                                            '
    __bliman_echo_no_colour '       --projectdesc: Description of project to be created                                         '
    __bliman_echo_no_colour '       --visibility: Visibility of project public / private /internal                              '
    __bliman_echo_no_colour '       --file: Path to the file to parse the project details from a file instead of above command line'
    __bliman_echo_no_colour '               options. Format of file should be as below.                                         '
    __bliman_echo_no_colour '       <gitlab|github>:<project name>:<project description>:<project visibility> '
    __bliman_echo_no_colour '       replace with the values and remove < and > from each field.'
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli create user --file <path of the users file>                                                '
    __bliman_echo_no_colour '  $ bli create project --token <user token> --file <path of the users file>                        '
    __bliman_echo_no_colour '  $ bli create labuser --lab <github|gitlab> --firstname <user first name> --lastname <user last name> --username <username> --useremail <xyz@abc,.com> --isadmin <true|false>'
    __bliman_echo_no_colour '  $ bli create labproject --token <user token> --projectname <name of project> --projectdesc <project descr> --namespace <namespace for the project> --visibility <public|private|internal>'
    __bliman_echo_no_colour '  '
}

function __bli_help_load {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   load - To load the environment variables defined in Genesis file for BeSLab.                    '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '   $ bli load                                                                                         '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   The bli load command fascilitate the BeSLab admin to prepare environment for the BeSlab to be   '
    __bliman_echo_no_colour '   installed in a mode specified. Every lab mode does need certain tools and configuration to be   '
    __bliman_echo_no_colour '   set to get the BeSLab components installed. initmode command helps to get the required          '
    __bliman_echo_no_colour '   dependencies for BeSLab in a particular mode gets installed on the machine.                     '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli load                                                                                       '
    __bliman_echo_no_colour '  '
}

function __bli_help_initmode {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   initmode - To initialize the lab installation mode (host | bare | lite)                         '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '   $ bli initmode <modename>                                                                          '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   The bli initmode command fascilitate the BeSLab admin to prepare environment for the BeSlab to be'
    __bliman_echo_no_colour '   installed in a mode specified. Every lab mode does need certain tools and configuration to be set'
    __bliman_echo_no_colour '   to get the BeSLab components installed. initmode command helps to get the command helps to get   '
    __bliman_echo_no_colour '   required dependencies for BeSLab in a particular mode gets installed on the machine.             '
    __bliman_echo_cyan      '   Available modes are:                                                                             '
    __bliman_echo_cyan      '      host - This mode installs lab on a virtual machine.                                           '
    __bliman_echo_cyan      '      bare - In this mode lab is installed on local or remote machine using ansible roles.          '
    __bliman_echo_cyan      '      lite - Lite mode is the lightweight mode and installs the lab using only shell scripts.       '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli initmode lite                                                                               '
    __bliman_echo_no_colour '  $ bli initmode bare                                                                               '
    __bliman_echo_no_colour '  $ bli initmode host                                                                               '
    __bliman_echo_no_colour '  '
}

function __bli_help_launchlab {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   launchlab - To install the lab in the mode specified by initmode command.                        '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '  $ bes launchlab                                                                                      '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   Install all the lab components and configure them as specified in Genesis file.                  '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli launchlab                                                                                   '
    __bliman_echo_no_colour '  '
}

function __bli_help_list {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   list - To list the available modes for beslab to get installed.                                  '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  ' 
    __bliman_echo_yellow '      $ bli list                                                                                       '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   It provides users with a comprehensive overview of all the available beslab modes, playbooks and '
    __bliman_echo_no_colour '   roles for the installation.                                                                      '    
    __bliman_echo_no_colour '  '
}

function __bli_help_status {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   status - List of installed lab components and tools.                                             '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '    $ bli status                                                                                       '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   Displays the list of installed lab components and tools                                          '   
    __bliman_echo_no_colour '  '
}


function __bli_help_help {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   help - Displays the BLIman help command.                                                         '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '      $ bli help '
    __bliman_echo_no_colour 'Display help for specific command -                                                                 '
    __bliman_echo_yellow '      $ bli help <command name>                                                                        '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   It displays the description of BLIman, details and list of BLIman commands.                      '  
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli help install                                                                                ' 
    __bliman_echo_no_colour '  $ bli help list                                                                                   '
    __bliman_echo_no_colour '  '
}

function __bli_help_version {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   version - Displays the version of BLIman utility.                                               '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '    $ bli --version                                                                                   '  
    __bliman_echo_no_colour '  '
}

function __bli_help_attest_OSAR {
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   attest - Attest OSAR reports.                                                                   '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '    $ bli attest [local | remote] [OPTIONS]                                                            '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   Used to attest the OSAR reports generted for POI and MOI.                                        '
    __bliman_echo_no_colour '   Subcommands:'
    __bliman_echo_no_colour '       local: To attest the OSAR report copied to local system.                                     '
    __bliman_echo_no_colour '         Options for local:'
    __bliman_echo_no_colour '            --path: (Mandatory) Path to the directory of OSAR file to be attested.                  '
    __bliman_echo_no_colour '            --file: (Mandatory) Name of the OSAR file to be attested.                               '
    __bliman_echo_no_colour '            --key-based: (Mandatory) True or False. True is key based attestation is used else false'
    __bliman_echo_no_colour '                         As of now only Key based attestation is enabled.                         '
    __bliman_echo_no_colour '            --key-path : (Mandatory only if Key-based is true) path for the attestation key.        '
    __bliman_echo_no_colour '            --key-name : (Mandatory only if Key-based is true) name of the key filefor the attestation'
    __bliman_echo_no_colour '       remote: To attest the OSAR report from a github ot gitlab repo.                              '
    __bliman_echo_no_colour '         Options for remote:'
    __bliman_echo_no_colour '            --remote-url: (Mandatory) URL for the github / gitlab.                                  '
    __bliman_echo_no_colour '            --repo-name : (Mandatory) Name of the POI or MOI OSAR file to be attested.              '
    __bliman_echo_no_colour '            --filepath  : (Mandatory) Path of the folder under POI or MOI root containing OSAR report'
    __bliman_echo_no_colour '            --filename  : (Mandatory) Name of the OSAR file to be attested.        '
    __bliman_echo_no_colour '            --key-based : (Mandatory) True or False. If true key based attestation is used. As of now'
    __bliman_echo_no_colour '                           only key based attestation is enabled.                                    '
    __bliman_echo_no_colour '            --key-path : (Mandatory if key-based is true) Path for the attestation key.              '
    __bliman_echo_no_colour '            --key-name : (Mandatory if key-based is true) Name of the file for attestation key.      '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli attest local --path <OSAR file path> --file <OSAR name> --key-based <True | False> --key-path <path of key> --key-name <name of key>'
    __bliman_echo_no_colour '  $ bli attest remote --remote-url <github/gitlab url> --repo-name <name of POI/MOI> --filepath <path od OSAR file in MOI/POI> --filename <name of OSAR file> --key-based <True | False> --key-path <path for key> --key-name <name of key>'
    __bliman_echo_no_colour '  '
}

function __bli_help_verify_OSAR {

    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   verify - Verify OSAR reports.                                                                   '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '    $ bli verify [local | remote] [OPTIONS]                                                            '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'DESCRIPTION'
    __bliman_echo_no_colour '   Used to verify attestation of the OSAR reports generted for POI and MOI.                         '
    __bliman_echo_no_colour '   Subcommands:'
    __bliman_echo_no_colour '       local: To verify the OSAR report copied to local system.                                     '
    __bliman_echo_no_colour '         Options for local:'
    __bliman_echo_no_colour '            --osar-path: (Mandatory) Path to OSAR file to be attested.                              '
    __bliman_echo_no_colour '            --auth-type: (Mandatory) key-based | keyless-bundle | keyless-non-bundle.               '
    __bliman_echo_no_colour '                         key-based: To verify the OSAR which is signed by key.                      '
    __bliman_echo_no_colour '                         keyless-bundle: To verify the OSAR which is signed by keyless bundle type.'
    __bliman_echo_no_colour '                         keyless-non-bundle: To verify the OSAR which is signed by keyless non-bundle.'
    __bliman_echo_no_colour '                         [ ** As of now only key-based attestation are enabled ** ]                 '
    __bliman_echo_no_colour '            --key-path : (Mandatory only if Key-based) Path for the key.                            '
    __bliman_echo_no_colour '            --sig-path : (Mandatory only if Key-based) Path of the signature file for the attestation.'
    __bliman_echo_no_colour '            --bundle-path : (Mandatory only if Keyless-bundle) Path of the bundle file for the attestation.'
    __bliman_echo_no_colour '            --pem-path : (Mandatory only if Keyless-non-bundle) Path of the certificate file for the attestation.'
    __bliman_echo_no_colour '       remote: To verify the OSAR report from a github ot gitlab repo.                              '
    __bliman_echo_no_colour '         Options for remote:'
    __bliman_echo_no_colour '            --OSAR-url  : (Mandatory) URL for the github / gitlab for OSAR file to download.        '
    __bliman_echo_no_colour '            --auth-type: (Mandatory) key-based | keyless-bundle | keyless-non-bundle.               '
    __bliman_echo_no_colour '                         key-based: To verify the OSAR which is signed by key.                      '
    __bliman_echo_no_colour '                         keyless-bundle: To verify the OSAR which is signed by keyless bundle type.'
    __bliman_echo_no_colour '                         keyless-non-bundle: To verify the OSAR which is signed by keyless non-bundle.'
    __bliman_echo_no_colour '                         [ ** As of now only key-based attestation are enabled ** ]                 '
    __bliman_echo_no_colour '            --sig-url  : (Mandatory if auth is key-based or keyless-non-bundle) URL of the signature file to download.    '
    __bliman_echo_no_colour '            --key-url  : (Mandatory if auth is key-based) URL of key file to download'
    __bliman_echo_no_colour '            --bundle-url  : (Mandatory if auth is keyless-bundle) URL for the bundle file to download.'
    __bliman_echo_no_colour '            --pem-url : (Mandatory if auth is keyless-non-bundl) URL for pem file to download.        '
    __bliman_echo_white 'EXAMPLE'
    __bliman_echo_no_colour '  $ bli verify local --osar-path <OSAR file path> --auth-type <key-based | keyless-bundle | keyless-non-bundle> --key-path <path of key> --sig-path <path of sig file>'
    __bliman_echo_no_colour '  $ bli verify remote --OSAR-url <github/gitlab url> --auth-type <key-based | keyless-bundle | keyless-non-bundle> --sig-url <URL for signature file> --key-file <URL for the key file>'
    __bliman_echo_no_colour '  '


     --OSAR-url)
                       [[ ! -z $2 ]] && OSAR_REMOTE_URL=$2
                       shift
                       ;;
               --auth-type)
                       [[ ! -z $2 ]] && AUTH_TYPE=$2
                       shift
                       ;;
               --sig-url)
                       [[ ! -z $2 ]] && SIGNATURE_URL=$2
                       shift
                       ;;
               --bundle-url)
                       [[ ! -z $2 ]] && BUNDLE_URL=$2
                       shift
                       ;;
               --key-url)
                       [[ ! -z $2 ]] && KEY_URL=$2
                       shift
                       ;;
               --pem-url)
                       [[ ! -z $2 ]] && PEM_URL=$2
                       shift
                       ;;
              *)
                      __bliman_echo_red "Not a valid parameter."
                       ;;
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'NAME'
    __bliman_echo_no_colour '   version - Displays the version of BLIman utility.                                               '
    __bliman_echo_no_colour '  '
    __bliman_echo_white 'SYNOPSIS  '
    __bliman_echo_yellow '    $ bes --version                                                                                   '
    __bliman_echo_no_colour '  '
}

