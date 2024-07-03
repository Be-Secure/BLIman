#!/bin/ bash

function create_users_by_file () {
   [[ -z $1 ]] && __bliman_echo_red "No path provided for file." && return 1

   while IFS=: read -r labname firstname lastname username email pass isadmin isexternal isprivate
   do

      if [ ! -z $labname ] && [ $labnamne == "gitlab" ] && [ ! -z $email ] && [ ! -z $pass ] && [ ! -z $username ] && [ ! -z $firstname ];then 
          sudo gitlab-rails runner "u = User.new(username: '$userName', email: '$email', name: '$firstname $lastname ', password: '$pass', password_confirmation: '$pass', admin: '$isadmin'); u.assign_personal_namespace; u.skip_confirmation! ; u.save! " 2>&1
          if [ xx"$?" == xx"0" ];then
             __bliman_echo_green "User $firstname created with $username"
          else
             __bliman_echo_red "Error in creating user $firstname with $username"
	  fi
      elif [ -z $labname ] || [ $labnamne == "github" ];then 
	      __bliman_echo_red "$labname is not a valid code collaboration platform or not supported yet"
	      return 1
      else
	       __bliman_echo_red "Not all required data is provided for creation of user." 
              return 1
      fi
   done < "$1"
}

function create_projects_by_file () {
   [[ -z $2 ]] && __bliman_echo_red "No path provided for file." && return 1

   [[ -z $1 ]] && __bliman_echo_red "User token is required." && return 1

   while IFS=: read -r reponame repodesc namespace visibility
   do

     if [ ! -z $labname ] && [ $labnamne == "gitlab" ] && [ ! -z $reponame ] && [ ! -z $visibility ] && [ ! -z $namespace  ];then
	     CODE=$(curl -k -sS -o curloutput -w '%{http_code}' --request POST --header "PRIVATE-TOKEN: $1" --header 'Content-Type: application/json' --data  "{\"name\": \"$reponame\", \"description\": \"$repodesc\",\"namespace\": \"$namespace\", \"initialize_with_readme\": \"true\", \"visibility\": \"$visibility\" }" --url 'http://localhost/api/v4/projects/' 2>&1)

        if [[ "$CODE" =~ ^2 ]];then
            __bliman_echo_green "Project $reponame is created from file $2."
	else
            __bliman_echo_red "Error in creating project $reponame."
	fi
     elif [ -z $labname ] || [ $labnamne == "github" ];then
              __bliman_echo_red "$labname is not a valid code collaboration platform or not supported yet"
              return 1
     else
               __bliman_echo_red "Not all required data is provided for creation of user."
              return 1
     fi

   done < "$2"
}

function  create_lab_user () {
   [[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "create" && return 1

   local options=()
   local optArg=()

   while [[ -n $1 ]]; do
       case $1 in
	       --lab)
		       [[ ! -z $2 ]] && LAB_BRAND=$2
		       shift
		       ;;
	       --firstname)
		       [[ ! -z $2 ]] && USER_FIRST_NAME=$2
                       shift
		       ;;
	       --lastname)
		       [[ ! -z $2 ]] && USER_LAST_NAME=$2
                       shift
		       ;;
	       --username)
		       [[ ! -z $2 ]] && USERNAME=$2
                       shift
		       ;;
	       --useremail)
		       [[ ! -z $2 ]] && USER_EMAIL=$2
                       shift
		       ;;
	       --password)
		       [[ ! -z $2 ]] && USER_PASS=$2
                       shift
		       ;;
	       --isadmin)
		       [[ ! -z $2 ]] && IS_ADMIN=$2
                       shift
		       ;;
	       --isexternal)
		       [[ ! -z $2 ]] && IS_EXTERNAL=$2
                       shift
		       ;;
	       --isprivate)
		       [[ ! -z $2 ]] && IS_PRIVATE=$2
                       shift
		       ;;
	       --file)
		       [[ ! -z $2 ]] && USERS_FILEPATH=$2
		       FILEREAD="y"
		       ;;
	       *)
		       __bliman_echo_red "Invalid gitlab user parameters passed."
		       ;;
        esac

	if [[ xx"$FILEREAD" == xx"y" ]];then
           break;
        else
          shift
	fi
   done

   if [ -z $FILEREAD ] && [ xx"$LAB_BRAND" == xx"gitlab" ] && [ ! -z $USERNAME ] && [ ! -z $USER_EMAIL ] && [ ! -z $USER_PASS ] && [ ! -z $USER_FIRST_NAME ];then
      sudo gitlab-rails runner "u = User.new(username: '$USERNAME', email: '$USER_EMAIL', name: '$USER_FIRST_NAME $USER_LAST_NAME ', password: '$USER_PASSS', password_confirmation: '$USER_PASS', admin: '$IS_ADMIN'); u.assign_personal_namespace; u.skip_confirmation! ; u.save! " 2>&1

      if [ xx"$?" == xx"0" ];then
             __bliman_echo_green "User $firstname created with $username"
      else
             __bliman_echo_red "Error in creating user $firstname with $username from file $1" 
      fi

   elif [ xx"$FILEREAD" == xx"y" ] && [ xx"$LAB_BRAND" == xx"gitlab" ];then
      
      ([[ -z $USERS_FILEPATH ]] || [[ ! -f $USERS_FILEPATH ]] ) && __bliman_echo_red "Not able to find the users file at $USERS_FILEPATH" && return 1
      create_users_by_file "$USERS_FILEPATH"
   else
	   __bliman_echo_red "Not all required paramters are passed." return 1
   fi
}

function  create_lab_project () {
   [[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "create" && return 1

   local options=()
   local optArg=()
 
   while [[ -n $1 ]]
   do
       case $1 in
               --lab)
                       [[ ! -z $2 ]] && LAB_BRAND=$2
                       shift
                       ;;
               --usertoken)
                       [[ ! -z $2 ]] && USER_TOKEN=$2
                       shift
                       ;;
               --projectname)
                       [[ ! -z $2 ]] && USER_PROJECT_NAME=$2
                       shift
                       ;;
               --projectdesc)
                       [[ ! -z $2 ]] && USER_PROJECT_DESC=$2
                       shift
                       ;;
	       --namespace)
                       [[ ! -z $2 ]] && USER_NAMSPACE=$2
                       shift
		       ;;
               --visibility)
                       [[ ! -z $2 ]] && PROJECT_VISIBILITY=$2
                       shift
                       ;;
	      --file)
                       [[ ! -z $2 ]] && PROJECTS_FILEPATH=$2
                       PROFILEREAD="y"
		       ;;
              *)
		      __bliman_echo_red "Not a valid gitlab project parameter."
                       ;;
        esac

        if [ xx"$PROFILEREAD" == xx"y" ] && [ ! -z $USER_TOKEN ];then
           break;
	elif [ xx"$PROFILEREAD" == xx"y" ] && [ -z $USER_TOKEN ];then
	     continue
        else
          shift
        fi

   done

    if [ -z $PROFILEREAD ] && [ xx"$LAB_BRAND" == xx"gitlab" ] && [ ! -z $USER_TOKEN ] && [ ! -z $USER_PROJECT_NAME ] && [ ! -z $USER_NAMESPACE ] && [  ! -z $PROJECT_VISIBILITY ];then
	    CODE=$(curl -k -sS -o curloutput -w '%{http_code}' --request POST --header "PRIVATE-TOKEN: $USER_TOKEN" --header 'Content-Type: application/json' --data  "{\"name\": \"$USER_PROJECT_NAME\", \"description\": \"$USER_PROJECT_DESC\",\"namespace\": \"$USER_NAMESPACE\", \"initialize_with_readme\": \"true\", \"visibility\": \"$PROJECT_VISIBILITY\" }" --url 'http://localhost/api/v4/projects/' 2>&1 )
        if [[ "$CODE" =~ ^2 ]];then
            __bliman_echo_green "Project $reponame is created."
        else
            __bliman_echo_red "Error in creating project $reponame."
        fi
    
    elif [ xx"$PROFILEREAD" == xx"y" ] && [ ! -z $USER_TOKEN ];then

	    ([[ -z $PROJECTS_FILEPATH ]] || [[ ! -f $PROJECTS_FILEPATH ]] ) && __bliman_echo_red "Not able to find the projects file at $PROJECTS_FILEPATH" && return 1
	    create_projects_by_file "$USER_TOKEN" "$PROJECTS_FILEPATH"
    
    elif [ xx"$PROFILEREAD" == xx"y" ] && [ -z $USER_TOKEN ];then
	     __bliman_echo_red "User token is needed for project creation. Missing." return 1

    elif ([ -z $LAB_BRAND ] || [ xx"$LAB_BRAND" == xx"github" ]) && [ xx"$PROFILEREAD" != xx"y" ];then
	  __bliman_echo_red "Not a valid code collaborator platform or not supported plarform for lab." 
	  return 1

    else
	  __bliman_echo_red "Not all required parameters are passed."
          return 1
    fi
}

function __bliman_create () {
   subcommand=$1

   [[ -z $subcommand ]] && __bliman_echo_red "Not valid command" && return 1

   case $subcommand in
	   labuser)
		   create_lab_user $[@:2] 
		   ;;
	   labproject)
		   create_lab_project $[@:2]
		   ;;
	   *)
		   __bliman_echo_red "Not a valid subcommand." && return 1
   esac

   return 0
}
