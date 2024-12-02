#!/bin/ bash

function verify_file_remote () {
    osar_url=$1
    auth_type=$2
    sig_url=$3
    bundle_url=$4
    key_url=$5
    pem_url=$6

    if [ -z $(command -v cosign) ];then
      __bliman_echo_yellow "Installing cosign ..."
      LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
      curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
      sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb

      rm -rf cosign_${LATEST_VERSION}_amd64.deb
    fi

    presentdir=$(pwd)
    mkdir -p $presentdir/stage
    cd stage
    curl -O -L $osar_url
    osar_name=echo "$osar_url" | awk -F'[/"]' '{ print $(NF-1); }'

    [[ ! -f $osar_name ]] && __bliman_echo_red "OSAR file not downloaded" && return 1

    if [ xx"$auth_type" == xx"key-based" ];then

       curl -O -L $key_url
       key_name=echo "$key_url" | awk -F'[/"]' '{ print $(NF-1); }'

       curl -O -L $sig_url
       sig_name=echo "$sig_url" | awk -F'[/"]' '{ print $(NF-1); }'

       [[ ! -f $key_name ]] && __bliman_echo_red "Key file not downloaded" && return 1
       [[ ! -f $sig_name ]] && __bliman_echo_red "Signature file not downloaded" && return 1

       cosign verify-blob --key $key_name --signature $sig_name $osar_name

    elif [ xx"$auth_type" == xx"keyless-bundle" ];then

       curl -O -L $bundle_url
       bundle_name=echo "$bundle_url" | awk -F'[/"]' '{ print $(NF-1); }'

       [[ ! -f $bundle_name ]] && __bliman_echo_red "Bundle file not downloaded" && return 1

       cosign verify-blob --bundle $bundle_name $sig_name $osar_name

    elif [ xx"$auth_type" == xx"keyless-non-bundle" ];then

       curl -O -L $pem_url
       pem_name=echo "$pem_url" | awk -F'[/"]' '{ print $(NF-1); }'

       curl -O -L $sig_url
       sig_name=echo "$sig_url" | awk -F'[/"]' '{ print $(NF-1); }'

       [[ ! -f $pem_name ]] && __bliman_echo_red "PEM file not downloaded" && return 1
       [[ ! -f $sig_name ]] && __bliman_echo_red "Signature file not downloaded" && return 1

       cosign verify-blob --cert $pem_name --signature $sig_name $osar_name
    fi

    cd $presentdir
    rm -rf $presentdir/stage

}

function verify_file_local () {
    osar_path=$1
    auth_type=$2
    bundle_path=$3
    sig_path=$4
    pem_path=$5

    if [ -z $(command -v cosign) ];then
      __bliman_echo_yellow "Installing cosign ..."
      LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
      curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
      sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb

      rm -rf cosign_${LATEST_VERSION}_amd64.deb
    fi

    mkdir -p $presentdir/stage
    cd stage
    curl -O -L $osar_path
    osar_name=echo "$osar_path" | awk -F'[/"]' '{ print $(NF-1); }'

    [[ ! -f $osar_path ]] && __bliman_echo_red "OSAR file not found" && return 1
    cp $osar_path .

    if [ xx"$auth_type" == xx"key-based" ];then

       curl -O -L $key_path
       key_name=echo "$key_path" | awk -F'[/"]' '{ print $(NF-1); }'

       curl -O -L $sig_path
       sig_name=echo "$sig_path" | awk -F'[/"]' '{ print $(NF-1); }'

       [[ ! -f $key_path ]] && __bliman_echo_red "Key file not found" && return 1
       [[ ! -f $sig_path ]] && __bliman_echo_red "Signature file not found" && return 1

       cp $key_path .
       cp $sig_path .

       cosign verify-blob --key $key_name --signature $sig_name $osar_name

    elif [ xx"$auth_type" == xx"keyless-bundle" ];then

       curl -O -L $bundle_url
       bundle_name=echo "$bundle_url" | awk -F'[/"]' '{ print $(NF-1); }'

       [[ ! -f $bundle_path ]] && __bliman_echo_red "Bundle file not found" && return 1
       cp $bundle_path
       cosign verify-blob --bundle $bundle_name $sig_name $osar_name

    elif [ xx"$auth_type" == xx"keyless-non-bundle" ];then

       curl -O -L $pem_url
       pem_name=echo "$pem_url" | awk -F'[/"]' '{ print $(NF-1); }'

       curl -O -L $sig_url
       sig_name=echo "$sig_url" | awk -F'[/"]' '{ print $(NF-1); }'

       [[ ! -f $pem_path ]] && __bliman_echo_red "PEM file not found" && return 1
       [[ ! -f $sig_path ]] && __bliman_echo_red "Signature file not found" && return 1
       cp $pem_path .
       cp $sig_path .
       cosign verify-blob --cert $pem_name --signature $sig_name $osar_name
    fi

    cd $presentdir
    rm -rf $presentdir/stage
}

function  verify_local () {
   [[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "attest-OSAR" && return 1

   while [[ -n $1 ]]
   do
       case $1 in
               --osar-path)
                       [[ ! -z $2 ]] && OSAR_PATH=$2
                       shift
                       ;;
               --auth-type)
                       [[ ! -z $2 ]] && AUTH_TYPE=$2
                       shift
                       ;;
               --key-path)
                       [[ ! -z $2 ]] && KEY_PATH=$2
                       shift
                       ;;
	       --bundle-path)
		       [[ ! -z $2 ]] && BUNDLE_PATH=$2
                       shift
                       ;;
	       --pem-path)
		       [[ ! -z $2 ]] && PEM_PATH=$2
                       shift
		       ;;
	       --sig-path)
                       [[ ! -z $2 ]] && SIG_PATH=$2
                       shift
                       ;;
              *)
		      __bliman_echo_red "Not a valid parameter."
                       ;;
        esac

        shift

   done

   [[ -z $OSAR_PATH ]] &&  __bliman_echo_red "OSAR file path is mandatory parameter." && return 1
   [[ -z $AUTH_TYPE ]] &&  __bliman_echo_red "Auth type is required parameter." && return 1
   

   if [ xx"$AUTH_TYPE" == xx"key-based" ];then
     [[ -z $SIG_PATH ]] &&  __bliman_echo_red "Signature file PATH is required for key-based attestation." && return 1
     [[ -z $KEY_PATH ]] &&  __bliman_echo_red "Public key file PATH is required for key-based attestation." && return 1
   elif [ xx"$AUTH_TYPE" == xx"keyless-bundle" ];then
     ## Disabled as of now
      __bliman_echo_red "Keyless attestation is not enabled as of now." && return 1
     [[ -z $BUNDLE_PATH ]] &&  __bliman_echo_red "Bundle file PATH is required for key-less bundled attestation." && return 1
   elif [ xx"$AUTH_TYPE" == xx"keyless-non-bundle" ];then
      ## Disabled as of now
     __bliman_echo_red "Keyless attestation is not enabled as of now." && return 1	   
     [[ -z $SIG_PATH ]] &&  __bliman_echo_red "Signature file PATH is required for key-less non bundled attestation." && return 1
     [[ -z $PEM_PATH ]] &&  __bliman_echo_red "PEM certificate file PATH is required for key-less non-bundled attestation." && return 1
   fi

   verify_file_local $OSAR_PATH $AUTH_TYPE $OSAR_PATH $SIG_PATH $KEY_PATH $PEM_PATH

}

function  verify_remote () {

   [[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "attest-OSAR" && return 1

   while [[ -n $1 ]]
   do
       case $1 in
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
        esac

        shift

   done

   [[ -Z $OSAR_REMOTE_URL ]] &&  __bliman_echo_red "OSAR remote url is required." && return 1
   [[ -z $AUTH_TYPE ]] && __bliman_echo_red "Auth type is required parameter." && return 1
   
   if [ xx"$AUTH_TYPE" == xx"key-based" ];then
     [[ -z $SIGNATURE_URL ]] &&  __bliman_echo_red "Signature file URL is required for key-based attestation." && return 1
     [[ -z $KEY_URL ]] &&  __bliman_echo_red "Public key file URL is required for key-based attestation." && return 1
   elif [ xx"$AUTH_TYPE" == xx"keyless-bundle" ];then
     [[ -z $BUNDLE_URL ]] &&  __bliman_echo_red "Bundle file URL is required for key-less bundled attestation." && return 1
   elif [ xx"$AUTH_TYPE" == xx"keyless-non-bundle" ];then
     [[ -z $SIGNATURE_URL ]] &&  __bliman_echo_red "Signature file URL is required for key-less non bundled attestation." && return 1
     [[ -z $PEM_URL ]] &&  __bliman_echo_red "PEM certificate file URL is required for key-less non-bundled attestation." && return 1 
   fi

   verify_file_remote $OSAR_REMOTE_URL $AUTH_TYPE $SIGNATURE_URL $BUNDLE_URL $KEY_URL $PEM_URL
}

function __bli_verify_OSAR () {
   subcommand=$1

   [[ -z $subcommand ]] && __bliman_echo_red "Not valid command" && return 1

   case $subcommand in
	   local)
		   verify_local ${@:2} 
		   ;;
	   remote)
		   verify_remote ${@:2}
		   ;;
	   *)
		   __bliman_echo_red "Not a valid subcommand." && return 1
   esac

   return 0
}
