#!/bin/ bash

function create_users_by_file() {
	[[ -z $1 ]] && __bliman_echo_red "No path provided for file." && return 1
	pass='Welc0me@123'
	while IFS=: read -r labname firstname lastname username email isadmin isexternal isprivate; do

		if [[ ! -z $labname && "$labname" =~ ^gitlab && ! -z $email && ! -z $username && ! -z $firstname ]]; then

			sudo gitlab-rails runner "u = User.new(username: '$userName', email: '$email', name: '$firstname $lastname ', password: '$pass', password_confirmation: '$pass', admin: '$isadmin'); u.assign_personal_namespace; u.skip_confirmation! ; u.save! " 2>&1
			if [ xx"$?" == xx"0" ]; then
				__bliman_echo_green "User $firstname created with $username"
			else
				__bliman_echo_red "Error in creating user $firstname with $username"
			fi

		elif [[ -z $labname || "$labname" =~ ^github ]]; then
			__bliman_echo_red "$labname is not a valid code collaboration platform or not supported yet"
			return 1
		else
			__bliman_echo_red "Not all required data is provided for creation of user."
			return 1
		fi
	done <"$1"
}

function create_projects_by_file() {
	[[ -z $2 ]] && __bliman_echo_red "No path provided for file." && return 1

	[[ -z $1 ]] && __bliman_echo_red "User token is required." && return 1

	while IFS=: read -r labname reponame repodesc visibility; do
		if [[ ! -z $labname && $labname =~ ^gitlab && ! -z $reponame && ! -z $visibility ]]; then
			CODE=$(curl -k -sS --output /dev/null --write-out '%{http_code}' --request POST --header "PRIVATE-TOKEN: $1" --header 'Content-Type: application/json' --data "{\"name\": \"$reponame\", \"description\": \"$repodesc\", \"initialize_with_readme\": \"true\", \"visibility\": \"$visibility\" }" --url 'http://localhost/api/v4/projects/' 2>&1)

			if [[ "$CODE" =~ ^2 ]]; then
				__bliman_echo_green "Project $reponame is created from file $2."
			else
				__bliman_echo_red "Error in creating project $reponame."
			fi
		elif [[ -z $labname || "$labname" =~ ^github ]]; then
			__bliman_echo_red "$labname is not a valid code collaboration platform or not supported yet"
			return 1
		else
			__bliman_echo_red "Not all required data is provided for creation of project."
			return 1
		fi

	done <"$2"
}

function create_lab_user() {
	[[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "create" && return 1
	USER_PASS='Welc0me@123'
	IS_ADMIN='false'
	IS_EXTERNAL='true'
	IS_PRIVATE='true'

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

		if [[ xx"$FILEREAD" == xx"y" ]]; then
			break
		else
			shift
		fi
	done

	if [ -z $FILEREAD ] && [ xx"$LAB_BRAND" == xx"gitlab" ] && [ ! -z $USERNAME ] && [ ! -z $USER_EMAIL ] && [ ! -z $USER_FIRST_NAME ]; then
		sudo gitlab-rails runner "u = User.new(username: '$USERNAME', email: '$USER_EMAIL', name: '$USER_FIRST_NAME $USER_LAST_NAME ', password: '$USER_PASSS', password_confirmation: '$USER_PASS', admin: '$IS_ADMIN'); u.assign_personal_namespace; u.skip_confirmation! ; u.save! " 2>&1

		if [ xx"$?" == xx"0" ]; then
			__bliman_echo_green "User $USER_FIRST_NAME created with $USERNAME"
		else
			__bliman_echo_red "Error in creating user $USER_FIRST_NAME with $USERNAME"
		fi

	elif [ xx"$FILEREAD" == xx"y" ]; then

		[[ -z $USERS_FILEPATH || ! -f $USERS_FILEPATH ]] && __bliman_echo_red "Not able to find the users file at $USERS_FILEPATH" && return 1

		create_users_by_file "$USERS_FILEPATH"
	else
		__bliman_echo_red "Not all required paramters are passed." return 1
	fi
}

function create_lab_project() {
	[[ -z $1 ]] && __bliman_echo_red "No parameters provided" && __bli_help "create" && return 1
	SKIP_SHIFT="n"
	USER_PROJECT_DESC=""
	USER_NAMESPACE=""

	while [[ -n $1 ]]; do
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
			shift
			while [[ $# -gt 0 ]] && [[ ! $1 == --* ]]; do
				if [[ -z "$USER_PROJECT_DESC" ]]; then
					USER_PROJECT_DESC="$1"
					SKIP_SHIFT="y"
					shift
				elif [[ ! $1 == --* ]]; then
					USER_PROJECT_DESC="$USER_PROJECT_DESC $1"
					SKIP_SHIFT="y"
					shift
				fi
			done
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

		if [ xx"$PROFILEREAD" == xx"y" ] && [ ! -z $USER_TOKEN ]; then
			break
		elif [ xx"$PROFILEREAD" == xx"y" ] && [ -z $USER_TOKEN ]; then
			continue
		else
			if [[ xx"$SKIP_SHIFT" == xx"y" ]]; then
				SKIP_SHIFT="n"
			else
				shift
			fi
		fi

	done
	if [ -z $PROFILEREAD ] && [ xx"$LAB_BRAND" == xx"gitlab" ] && [ ! -z $USER_TOKEN ] && [ ! -z $USER_PROJECT_NAME ] && [ ! -z $PROJECT_VISIBILITY ]; then
		CODE=$(curl -k -sS --output /dev/null --write-out "%{http_code}" --request POST --header "PRIVATE-TOKEN: $USER_TOKEN" --header 'Content-Type: application/json' --data "{\"name\": \"$USER_PROJECT_NAME\", \"description\": \"$USER_PROJECT_DESC\", \"initialize_with_readme\": \"true\", \"visibility\": \"$PROJECT_VISIBILITY\" }" --url 'http://localhost/api/v4/projects/' 2>&1)
		if [[ "$CODE" =~ ^2 ]]; then
			__bliman_echo_green "Project $USER_PROJECT_NAME is created."
		else
			__bliman_echo_red "Error in creating project $USER_PROJECT_NAME."
		fi

	elif [ xx"$PROFILEREAD" == xx"y" ] && [ ! -z $USER_TOKEN ]; then

		([[ -z $PROJECTS_FILEPATH ]] || [[ ! -f $PROJECTS_FILEPATH ]]) && __bliman_echo_red "Not able to find the projects file at $PROJECTS_FILEPATH" && return 1
		create_projects_by_file "$USER_TOKEN" "$PROJECTS_FILEPATH"

	elif [ xx"$PROFILEREAD" == xx"y" ] && [ -z $USER_TOKEN ]; then
		__bliman_echo_red "User token is needed for project creation. Missing." return 1

	elif [[ -z $LAB_BRAND || xx"$LAB_BRAND" == xx"github" ]] && [[ xx"$PROFILEREAD" != xx"y" ]]; then
		__bliman_echo_red "Not a valid code collaborator platform or not supported plarform for lab."
		return 1

	else
		__bliman_echo_red "Not all required parameters are passed."
		return 1
	fi
}

function get_plugin_template() {

	local plugin_name plugin_version
	plugin_name=$1
	plugin_version=$2
	cat <<-EOF
#!/bin/bash
# This is a template for a plugin.

function __bliman_init_${plugin_name}() {
	
	# Write the code to initialize the plugin here.
	# You can set variables/configurations here
	# Install a tool/package specific for this plugin
}

function __bliman_install_${plugin_name}() {
	
	# Write the code to install the plugin here.

}

function __bliman_uninstall_${plugin_name}() {
	# Write the code to uninstall the plugin here.
}

function __bliman_validate_${plugin_name}() {
	# Write the code to validate the installation of plugin here.
}

function __bliman_update_${plugin_name}() {
	# Write the code to update the plugin here.
}

function __bliman_reset_${plugin_name}() {
	# Write the code to reset the plugin to the original state here.
}

function __bliman_plugininfo_${plugin_name}() {
	cat <<-INFO
### Plugin Information

#### Name: ${plugin_name}

#### Description:

	# Give a detail description of what the plugin is and what it does.

#### Version:

	# Give the version of the plugin.

#### Default Port:

	# Give the default port for the plugin(if any).

#### Dependencies:

	# List the dependencies for the plugin that the user should have before running this plugin.

#### Usage:

	# Provide the steps to install the plugin.
	To use the plugin, run the following command:

	bli install plugin ${plugin_name} ${plugin_version}

INFO

}
EOF
}

function create_plugin() {

	local plugin_name plugin_version plugin_file_path
	plugin_name=$1
	plugin_version=$2

	if [[ -z "$plugin_name" ]]; then
		__bliman_echo_red "Error: Incorrect format"
		__bli_help_create_plugin
		return 1
	fi

	if [[ -z "$plugin_version" ]]; then
		__bliman_echo_yellow "No version specified, defaulting to 0.0.1"
		plugin_version="0.0.1"
	fi
   # moving here, otherwise the plugin_version will be empty
	plugin_file_path="$BLIMAN_PLUGINS_REPO_DIR/$plugin_name/$plugin_version/beslab-$plugin_name-$plugin_version-plugin.sh"


	if [[ ! -d "$BLIMAN_PLUGINS_REPO_DIR" ]]; then
		__bliman_echo_red "Could not find plugins directory: $BLIMAN_PLUGINS_REPO_DIR"
		return 1
	fi

	if [[ -d "$BLIMAN_PLUGINS_REPO_DIR/$plugin_name/$plugin_version" ]]; then
		__bliman_echo_yellow "Plugin $plugin_name $plugin_version already exists"
		__bliman_echo_no_colour "Exiting..."
		return 1
	fi

	mkdir -p "$BLIMAN_PLUGINS_REPO_DIR/$plugin_name/$plugin_version" || (bliman_echo_red "Error: Could not create plugin directory" && return 1)

	get_plugin_template "$plugin_name" "$plugin_version" > "$plugin_file_path" || (bliman_echo_red "Error: Could not write to plugin file" && return 1)

	__bliman_echo_green "Plugin $plugin_name $plugin_version created successfully"
}

function __bli_create() {
	subcommand=$1

	[[ -z $subcommand ]] && __bliman_echo_red "Not valid command" && return 1

	case $subcommand in
	labuser)
		create_lab_user ${@:2}
		;;
	labproject)
		create_lab_project ${@:2}
		;;
	plugin)
		create_plugin ${@:2}
		;;
	*)
		__bliman_echo_red "Not a valid subcommand." && return 1
		;;
	esac

	return 0
}
