Feature: Offline Mode

	# offline modes

	Scenario: Enter an invalid offline mode
		Given offline mode is disabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli offline grails"
		Then I see "Stop! grails is not a valid offline mode."

	Scenario: Issue Offline command without qualification
		Given offline mode is disabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli offline"
		Then I see "Offline mode enabled."

	Scenario: Enable Offline Mode with internet reachable
		Given offline mode is disabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli offline enable"
		Then I see "Offline mode enabled."
		And I do not see "INTERNET NOT REACHABLE!"
		When I enter "bli install grails 2.1.0"
		Then I do not see "INTERNET NOT REACHABLE!"
		And I see "Stop! grails 2.1.0 is not available while offline."

	Scenario: Disable Offline Mode with internet reachable
		Given offline mode is enabled with reachable internet
		And the candidate "grails" version "2.1.0" is available for download
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli offline disable"
		Then I see "Online mode re-enabled!"
		When I enter "bli install grails 2.1.0" and answer "Y"
		Then I see "Done installing!"
		And the candidate "grails" version "2.1.0" is installed

	Scenario: Disable Offline Mode with internet unreachable
		Given offline mode is enabled with unreachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli offline disable"
		Then I see "Online mode re-enabled!"
		When I enter "bli install grails 2.1.0"
		Then I see "INTERNET NOT REACHABLE!"
		And I see "Stop! grails 2.1.0 is not available while offline."

	# bli version

	Scenario: Determine the bliman version while in Offline Mode
		Given offline mode is enabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli version"
		Then I see the current bliman version

	# list candidate version

	Scenario: List candidate versions found while in Offline Mode
		Given offline mode is enabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli list grails"
		Then I see "Offline: only showing installed grails versions"

	# default version

	Scenario: Set the default to an uninstalled candidate version while in Offline Mode
		Given offline mode is enabled with reachable internet
		And the candidate "grails" version "1.3.9" is already installed and default
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli default grails 2.1.0"
		Then I see "Stop! grails 2.1.0 is not available while offline."

	# install command

	Scenario: Install a candidate version that is not installed while in Offline Mode
		Given offline mode is enabled with reachable internet
		And the candidate "grails" version "2.1.0" is not installed
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli install grails 2.1.0"
		Then I see "Stop! grails 2.1.0 is not available while offline."

	# uninstall command

	Scenario: Uninstall a candidate version while in Offline Mode
		Given offline mode is enabled with reachable internet
		And the candidate "grails" version "2.1.0" is already installed and default
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli uninstall grails 2.1.0"
		And the candidate "grails" version "2.1.0" is not installed

	# current command

	Scenario: Display the current version of a candidate while in Offline Mode
		Given offline mode is enabled with reachable internet
		And the candidate "grails" version "2.1.0" is already installed and default
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli current grails"
		Then I see "Using grails version 2.1.0"

	# help command

	Scenario: Request help while in Offline Mode
		Given offline mode is enabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli help"
		Then I see "Usage: bli <command> [candidate] [version]"

	# selfupdate command

	Scenario: Attempt self-update while in Offline Mode
		Given offline mode is enabled with reachable internet
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli selfupdate"
		Then I see "This command is not available while offline."
