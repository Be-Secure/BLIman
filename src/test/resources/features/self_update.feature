Feature: Self Update

	Background:
		Given the internet is reachable
		And the bliman scripts version is "5.0.0"
		And the bliman native version is "0.0.1"
		And an initialised environment
		And the system is bootstrapped
		And an available selfupdate endpoint

	Scenario: Attempt Self Update with out dated scripts components
		Given the bliman script version "6.0.0" is available for download
		And the bliman native version "0.0.1" is available for download
		When I enter "bli selfupdate"
		Then I see "Successfully upgraded BLIMAN."

	Scenario: Attempt Self Update with out dated native components
		Given the bliman script version "5.0.0" is available for download
		And the bliman native version "0.0.2" is available for download
		When I enter "bli selfupdate"
		Then I see "Successfully upgraded BLIMAN."

	Scenario: Attempt Self Update on an up to date system
		Given the bliman script version "5.0.0" is available for download
		And the bliman native version "0.0.1" is available for download
		When I enter "bli selfupdate"
		Then I see "No update available at this time."

	Scenario: Force Self Update on an up to date system
		Given the bliman script version "5.0.0" is available for download
		And the bliman native version "0.0.1" is available for download
		When I enter "bli selfupdate force"
		Then I see "Successfully upgraded BLIMAN."
	