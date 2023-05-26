package bliman.specs

import bliman.support.BlimanEnvSpecification

class CandidatesCacheUpdateSpec extends BlimanEnvSpecification {

	static final String CANDIDATES_API = "http://localhost:8080/2"

	static final String HEALTHCHECK_ENDPOINT = "$CANDIDATES_API/healthcheck"
	static final String CANDIDATES_ALL_ENDPOINT = "$CANDIDATES_API/candidates/all"

	File candidatesCache

	def setup() {
		candidatesCache = new File("${blimanDotDirectory}/var", "candidates")
		curlStub.primeWith(HEALTHCHECK_ENDPOINT, "echo dbfb025be9f97fda2052b5febcca0155")
				.primeWith(CANDIDATES_ALL_ENDPOINT, "echo groovy,scala")
		blimanBashEnvBuilder.withConfiguration("bliman_debug_mode", "true")
	}

	void "should issue a warning and escape if cache is empty"() {
		given:
		bash = blimanBashEnvBuilder
				.withCandidates([])
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bli version")

		then:
		bash.output.contains('WARNING: Cache is corrupt. BLIMAN cannot be used until updated.')
		bash.output.contains('$ bli update')

		and:
		!bash.output.contains("BLIMAN 5.0.0")
	}

	void "should log a success message if cache exists"() {
		given:
		bash = blimanBashEnvBuilder
				.withCandidates(['groovy'])
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bli help")

		then:
		bash.output.contains('Using existing cache')
	}

	void "should bypass cache check if update command issued"() {
		given:
		bash = blimanBashEnvBuilder
				.withCandidates([])
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("bli update")

		then:
		bash.output.contains('Adding new candidates(s): groovy scala')

		and:
		candidatesCache.text.trim() == "groovy,scala"
	}
}
