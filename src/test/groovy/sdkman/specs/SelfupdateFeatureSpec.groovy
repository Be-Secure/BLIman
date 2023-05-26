package bliman.specs

import bliman.support.BlimanEnvSpecification

import java.time.Instant

import static java.time.temporal.ChronoUnit.DAYS

class SelfupdateFeatureSpec extends BlimanEnvSpecification {
	static final String CANDIDATES_API = "http://localhost:8080/2"
	static final String HEALTHCHECK_ENDPOINT = "$CANDIDATES_API/healthcheck"
	static final String VERSION_ENDPOINT = "$CANDIDATES_API/broker/download/bliman/version/stable"
 
	def setup() {
		curlStub.primeWith(HEALTHCHECK_ENDPOINT, "echo dbfb025be9f97fda2052b5febcca0155")
		curlStub.primeWith(VERSION_ENDPOINT, "echo 5.0.0")
	}

	def "should list selfupdate as a valid command when the selfupdate feature is toggled on"() {
		given:
		bash = blimanBashEnvBuilder
			.withConfiguration("bliman_selfupdate_feature", selfUpdateFeature)
			.build()

		bash.start()
		bash.execute("source $bootstrapScript")

		when:
		bash.execute("bli help")

		then:
		verifyOutput(bash.output)

		where:
		selfUpdateFeature | verifyOutput
		"false"           | { !it.contains("selfupdate") }
		"true"            | { it.contains("selfupdate") }
	}

	def "should source bliman-selfupdate.sh when the selfupdate feature is toggled on"() {
		given:
		bash = blimanBashEnvBuilder
			.withConfiguration("bliman_selfupdate_feature", selfupdateFeature)
			.build()

		bash.start()
		bash.execute("source $bootstrapScript")

		when:
		bash.execute("bli selfupdate")

		then:
		verifyOutput(bash.output)

		where:
		selfupdateFeature | verifyOutput
		"false"           | { it.contains("Invalid command: selfupdate") }
		"true"            | { !it.contains("Invalid command: selfupdate") }
	}
}
