#!/bin/ bash

function printmanual () {
   __bliman_echo_yellow "Please upload the following files to the code collab tool used for the attesstation proof."
   __bliman_echo_yellow "For key-based attesstation:  "
   __bliman_echo_yellow "    <keyfilename>.pub        "
   __bliman_echo_yellow "                             "
   __bliman_echo_yellow "For key-less attesstation:   "
   __bliman_echo_yellow "    Bundled signature and pem"
   __bliman_echo_yellow "       <OSAR filename>.bundle"
   __bliman_echo_yellow "              OR             "
   __bliman_echo_yellow "    Seprate signature and pem"
   __bliman_echo_yellow "       <OSAR filename>.pem   "
   __bliman_echo_yellow "       <OSAR filename>.sig   "

}

function attest_file_remote () {
    remoteurl=$1
    reponame=$2
    filepath=$3
    filename=$4
    usingKey=$5
    keypath=$6
    keyname=$7

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
    git clone $remoteurl
    cd $reponame

    [[ ! -d $presentdir/stage/$reponame/$filepath ]] && __bliman_echo_red "Provided OSAR file path $presentdir/stage/$reponame/$filepath is not found." && return 1
    [[ ! -f $presentdir/stage/$reponame/$filepath/$filename ]] && __bliman_echo_red "Provided OSAR file $presentdir/stage/$reponame/$filepath/$filename is not found." && return 1

    cd $presentdir/stage/$reponame/$filepath

    if [ $usingKey == "true" ] || [ $usingKey == "True" ] || [ $usingKey == "TRUE" ] || [ $usingKey == "T" ];then
       if [ -z $keypath ] || [ -z $keyname ] || [ ! -d $keypath ] || [ ! -f $keypath/$keyname ];then
          __bliman_echo_red "Key file $keypath/$keyname is not found."
          __bliman_echo_yellow "Do you want to generate a key?"
          read -p "Enter \"Y\" to generate a key else \"N\"" genkey
          if [ xx"$genkey" == xx"Y" ];then
             cosign generate-key-pair
             keypath=$filepath
             keyname="cosign"

          elif [ xx"$genkey" == xx"N" ];then
              __bliman_echo_red "Key is manadatory for key based attestation. Provide key file or use keyless attestation." && return 1
          else
               __bliman_echo_red "Invalid input $genkey. Key is manadatory for key based attestation. Provide key file or use keyless attestation." && return 1
          fi
       elif  [ ! -z $keypath ] && [ ! -z $keyname ];then
	  [[ ! -f $keypath/$keyname ]] &&  __bliman_echo_red "Key file $keypath/$keyname is not found. Needed for key based atesstation." && return 1
       fi
    fi

    curdir=$(pwd)
    if [ $usingKey == "true" ] || [ $usingKey == "True" ] || [ $usingKey == "TRUE" ] || [ $usingKey == "T" ] ;then

         cosign sign-blob --key $keypath/$keyname.key $filename -y > $filename.sig
         if [ -f $curdir/cosign.pub ];then
               git add cosign.pub
	       git add $filename.sig
         elif [ -f $keypath/$keyname.pub ];then
               cp $keypath/$keyname.pub .

               git add $keyname.pub
	       git add $filename.sig
         else
               __bliman_echo_red "Key public file not found." && return 1
         fi
    elif [ $usingKey == "false" ] || [ $usingKey == "False" ] || [ $usingKey == "FALSE" ] || [ $usingKey == "F" ] ;then
        ## Feature is disapled as of now
       __bliman_echo_red "Only key based attestation are allowed for now."
       return 1

       __bliman_echo_cyan "Note:"
       __bliman_echo_cyan "For Keyless attestation you will need to capture the authentication code generated on a tab opened in browser when prompted."
       __bliman_echo_cyan "   In case of non-desktop/ cli based executions copy the link displayed on screen to a browser and login using the options shown."
       __bliman_echo_cyan "   Once logged in to the authenticator account i.e Github/ Google etc a code will be displayed on screen. Enter that code into session."
       __bliman_echo_cyan ""

       __bliman_echo_yellow "Do you want to use bundle or separate certificate and signature file?"
       read -p "Enter \"Y\" for bundle certifcate else \"N\"" usingbundle

       if [ xx"$usingbundle" == xx"Y" ];then

          cosign sign-blob $filename --bundle $filename.bundle -y

	  if [ -f $curdir/$filename.bundle ];then
               git add $filename.bundle
           else
               __bliman_echo_red "No attestation file is found." && return 1
           fi
       elif [ xx"$usingbundle" == xx"N" ];then

          cosign sign-blob $filename --output-certificate $filename.pem --output-signature $filename.sig -y
          if [ -f  $curdir/$filename.pem ] &&  [ -f  $curdir/$filename.sig ];then
               git add $filename.pem
               git add $filename.sig
          else
               __bliman_echo_red "No attestation file is found." && return 1
          fi
       
       else
               __bliman_echo_red "Invalid input $usingbundle" && return 1
       fi

    else
            __bliman_echo_red "Invalid value for --key-based. Only allowed values are True | False" && return 1
    fi

    git commit -a -m "Added attestation proof for $poimoiname version $poimoiversion"

    git push origin
    cd $presentdir
    rm -rf $presentdir/stage

}

function attest_file_local () {
    filepath=$1
    filename=$2
    usingKey=$3
    keypath=$4
    keyname=$5

    if [ -z $(command -v cosign) ];then
      __bliman_echo_yellow "Installing cosign ..."
      LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
      curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign_${LATEST_VERSION}_amd64.deb"
      sudo dpkg -i cosign_${LATEST_VERSION}_amd64.deb

      rm -rf cosign_${LATEST_VERSION}_amd64.deb
    fi

    presentdir=$(pwd)
    cd $filepath

    [[ ! -d $filepath ]] && __bliman_echo_red "OSAR file path $filepath is not found." && return 1
    [[ ! -f $filepath/$filename ]] && __bliman_echo_red "OSAR file $filepath/$filename is not found." && return 1

    if [ $usingKey == "true" ] || [ $usingKey == "True" ] || [ $usingKey == "TRUE" ] || [ $usingKey == "T" ];then
       if [ -z $keypath ] ||  [ -z $keyname ] || [ ! -f $keypath/$keyname ];then
          __bliman_echo_red "Key file $keypath/$keyname is not found."
	  __bliman_echo_yellow "Do you want to generate a key?"
          read -p "Enter \"Y\" to generate a key else \"N\"" genkey
	  if [ xx"$genkey" == xx"Y" ];then
             cosign generate-key-pair
	     keypath=$(pwd)
	     keyname="cosign"

          elif [ xx"$genkey" == xx"N" ];then
              __bliman_echo_red "Key is manadatory for key based attestation. Provide key file or use keyless attestation." && return 1
          else
               __bliman_echo_red "Invalid input $genkey. Key is manadatory for key based attestation. Provide key file or use keyless attestation." && return 1
          fi
       fi
    fi

    if [ $usingKey == "true" ] || [ $usingKey == "True" ] || [ $usingKey == "TRUE" ] || [ $usingKey == "T" ] ;then
       
         cosign sign-blob --key $keypath/$keyname.key $filename -y > $filename.sig

    elif [ $usingKey == "false" ] || [ $usingKey == "False" ] || [ $usingKey == "FALSE" ] || [ $usingKey == "F" ] ;then
       ## Feature is disapled as of now
       __bliman_echo_red "Only key based attestation are allowed for now."
       return 1

       __bliman_echo_cyan "Note:"
       __bliman_echo_cyan "For Keyless attestation you will need to capture the authentication code generated on a tab opened in browser when prompted."
       __bliman_echo_cyan "   In case of non-desktop/ cli based executions copy the link displayed on screen to a browser and login using the options shown."
       __bliman_echo_cyan "   Once logged in to the authenticator account i.e Github/ Google etc a code will be displayed on screen. Enter that code into session."
       __bliman_echo_cyan ""

       __bliman_echo_yellow "Do you want to use bundle or separate certificate and signature file?"
       read -p "Enter \"Y\" for bundle certifcate else \"N\"" usingbundle

       if [ xx"$usingbundle" == xx"Y" ];then

	  cosign sign-blob $filename --bundle $filename.bundle -y
       
       elif [ xx"$usingbundle" == xx"N" ];then

	  cosign sign-blob $filename --output-certificate $filename.pem --output-signature $filename.sig -y
       
       else
	       __bliman_echo_red "Invalid input $usingbundle" && return 1
       fi

    else
	    __bliman_echo_red "Invalid value for --key-based. Only allowed values are True | False" && return 1
    fi
    
    __bliman_echo_yellow "Do you want to push the attestation proof to git?"
    read -p "Enter \"Y\" for yes or \"N\" for no: " pushcert

    if [ xx"$pushcert" == xx"Y" ];then
          __bliman_echo_yellow "Do you want to push the attestation proof to git?"
	  read -p "Enter the code collab platform url e.g (https://github.com or http://gitlab.031E.com) : " giturl
	  read -p "Enter the namespace e.g (Be-Secure) : " gitnamespace
          read -p "Enter the assessment datastore repository name e.g (besecure-assement-datastore or besecure-ml-assessment_datastore): " datastorename
	  read -p "Enter the POI or MOI name: " poimoiname
          read -p "Enter the POI or MOI version: " poimoiversion

	  [[ -z $giturl ]] && __bliman_echo_red "Code collab platform url $giturl is not valid." && printmanual && return 1
	  [[ -z $gitnamespace ]] && __bliman_echo_red "Code collab platform name space $gitnamespace is not valid." && printmanual && return 1
	  [[ -z $datastorename ]] && __bliman_echo_red "Datastore name is not provided." && printmanual && return 1
	  [[ -z $poimoiname ]] && __bliman_echo_red "POI or MOI name is provided." && printmanual && return 1
	  [[ -z $poimoiversion ]] && __bliman_echo_red "POI and MOI version not provided." && printmanual && return 1

	  pdir=$(pwd)
          mkdir -p $pdir/stage
	  cd stage

          git clone $giturl/$gitnamespace/$datastorename.git

	  [[ -d $datastorename ]] && __bliman_echo_red "Not able to clone the datastore" && printmanual && return 1
	  cd $datastorename

	  if [ $usingKey == "true" ] || [ $usingKey == "True" ] || [ $usingKey == "TRUE" ] || [ $usingKey == "T" ];then
	    if [ -f $pdir/cosign.pub ] && [ -f $pdir/$filename.sig ];then
	       cp $pdir/cosign.pub .
	       cp $pdir/$filename.sig .
	       git add cosign.pub
	       git add $filename.sig
            elif [ -f $keypath/$keyname.pub ];then 
               cp $keypath/$keyname.pub .
	       cp $pdir/$filename.sig .
	       git add $keyname.pub
	       git add $filename.sig
            else
               __bliman_echo_red "Key public file not found." && return 1
	    fi
	  elif [ $usingKey == "false" ] || [ $usingKey == "False" ] || [ $usingKey == "FALSE" ] || [ $usingKey == "F" ];then

            if [ -f $pdir/$filename.bundle ];then
               cp $pdir/$filename.bundle $poimoiname/$poimoiversion/
               git add $poimoiname/$poimoiversion/$filename.bundle
            elif [ -f  $pdir/$filename.pem ] &&  [ -f  $pdir/$filename.sig ];then
               cp $pdir/$filename.pem $poimoiname/$poimoiversion/
	       cp $pdir/$filename.sig $poimoiname/$poimoiversion/

               git add $poimoiname/$poimoiversion/$filename.pem
	       git add $poimoiname/$poimoiversion/$filename.sig
            else
               __bliman_echo_red "No attestation file is found." && return 1
            fi		  
	  else
             __bliman_echo_red "Not a valid option." && return 1
	  fi

	  git commit -a -m "Added attestation proof for $poimoiname version $poimoiversion"

	  git push origin

	  cd $pdir
	  rm -rf $pdir/stage
    elif [ xx"$pushcert" == xx"N" ];then
         printmanual
          
    else
          __bliman_echo_red "Invalid input $pushcert" && return 1
    fi
    cd $presentdir
}

function  attest_local () {
   [[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "attest-OSAR" && return 1

   while [[ -n $1 ]]
   do
       case $1 in
               --path)
                       [[ ! -z $2 ]] && OSAR_PATH=$2
                       shift
                       ;;
               --file)
                       [[ ! -z $2 ]] && OSAR_FILE=$2
                       shift
                       ;;
               --key-based)
                       [[ ! -z $2 ]] && KEY_BASED=$2
                       shift
                       ;;
	       --key-path)
		       [[ ! -z $2 ]] && KEY_PATH=$2
                       shift
                       ;;
	       --key-name)
		       [[ ! -z $2 ]] && KEY_NAME=$2
                       shift
		       ;;
              *)
		      __bliman_echo_red "Not a valid parameter."
                       ;;
        esac

        shift

   done

   [[ -Z $OSAR_PATH ]] &&  __bliman_echo_red "OSAR file path is mandatory parameter." && return 1
   [[ -Z $OSAR_FILE ]] &&  __bliman_echo_red "OSAR file name is mandatory parameter." && return 1
   [[ -Z $KEY_BASED ]] &&  __bliman_echo_red "KEY based or keyless is required parameter." && return 1
   
   attest_file_local $OSAR_PATH $OSAR_FILE $KEY_BASED $KEY_PATH $KEY_NAME

}

function  attest_remote () {

   [[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "attest-OSAR" && return 1

   while [[ -n $1 ]]
   do
       case $1 in
               --remote-url)
                       [[ ! -z $2 ]] && OSAR_REMOTE_URL=$2
                       shift
                       ;;
	       --repo-name)
                       [[ ! -z $2 ]] && OSAR_REMOTE_REPO_NAME=$2
                       shift
                       ;;
               --filepath)
                       [[ ! -z $2 ]] && OSAR_REMOTE_FILE_PATH=$2
                       shift
                       ;;
	       --filename)
                       [[ ! -z $2 ]] && OSAR_REMOTE_FILE_NAME=$2
                       shift
                       ;;
               --key-based)
                       [[ ! -z $2 ]] && KEY_BASED=$2
                       shift
                       ;;
               --key-path)
                       [[ ! -z $2 ]] && KEY_PATH=$2
                       shift
                       ;;
               --key-name)
                       [[ ! -z $2 ]] && KEY_NAME=$2
                       shift
                       ;;
              *)
                      __bliman_echo_red "Not a valid parameter."
                       ;;
        esac

        shift

   done

   [[ -Z $OSAR_REMOTE_URL ]] &&  __bliman_echo_red "OSAR remote code collab repository url is mandatory parameter." && return 1
   [[ -z $OSAR_REMOTE_REPO_NAME ]] && __bliman_echo_red "OSAR remote repo name is required." && return 1
   [[ -Z $OSAR_REMOTE_FILE_PATH ]] &&  __bliman_echo_red "OSAR file path is mandatory parameter." && return 1
   [[ -Z $OSAR_REMOTE_FILE_NAME ]] &&  __bliman_echo_red "OSAR file path is mandatory parameter." && return 1
   [[ -Z $KEY_BASED ]] &&  __bliman_echo_red "KEY based or keyless is required parameter." && return 1

   attest_file_remote $OSAR_REMOTE_URL $OSAR_REMOTE_REPO_NAME $OSAR_REMOTE_FILE_PATH $OSAR_REMOTE_FILE_NAME $KEY_BASED $KEY_PATH $KEY_NAME
}

function __bli_attest_OSAR () {
   subcommand=$1

   [[ -z $subcommand ]] && __bliman_echo_red "Not valid command" && return 1

   case $subcommand in
	   local)
		   attest_local ${@:2} 
		   ;;
	   remote)
		   attest_remote ${@:2}
		   ;;
	   *)
		   __bliman_echo_red "Not a valid subcommand." && return 1
   esac

   return 0
}
