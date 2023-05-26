Feature: Version

	Scenario: Show the current version of bliman
		Given the internet is reachable
		And the bliman scripts version is "3.2.1"
		And an initialised environment
		And the system is bootstrapped
		When I enter "bli version"
		Then I see "BLIMAN 3.2.1"
