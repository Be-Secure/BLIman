Feature: Update

	Background:
		Given the internet is reachable
		And the following candidates are available for installation in local cache:
			| candidate |
			| activator |
			| groovy    |
			| scala     |
		And an initialised environment
		And the system is bootstrapped

	Scenario: A new candidate is available
		And the following candidates are currently available from remote API:
			| candidate |
			| activator |
			| groovy    |
			| kotlin    |
			| scala     |
		When I enter "bli update"
		Then I see "Adding new candidates(s): kotlin"
		And the Candidates cache should contain "activator,groovy,kotlin,scala"

	Scenario: A candidate has been removed
		And the following candidates are currently available from remote API:
			| candidate |
			| groovy    |
			| scala     |
		When I enter "bli update"
		Then I see "Removing obsolete candidates(s): activator"
		And the Candidates cache should contain "groovy,scala"

	Scenario: A new candidate is available and a candidate has been removed
		And the following candidates are currently available from remote API:
			| candidate |
			| groovy    |
			| kotlin    |
			| scala     |
		When I enter "bli update"
		Then I see "Removing obsolete candidates(s): activator"
		And I see "Adding new candidates(s): kotlin"
		And the Candidates cache should contain "groovy,kotlin,scala"

	Scenario: No new candidate is available
		And the following candidates are currently available from remote API:
			| candidate |
			| activator |
			| groovy    |
			| scala     |
		When I enter "bli update"
		Then I see "No new candidates found at this time."
		And the Candidates cache should contain "activator,groovy,scala"
