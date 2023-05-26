package bliman.specs

import bliman.support.BlimanEnvSpecification

import java.nio.file.Paths

import static java.nio.file.Files.createSymbolicLink

class CurrentCommandSpec extends BlimanEnvSpecification {

	static final CANDIDATES_API = "http://localhost:8080/2"
	static final HEALTHCHECK_ENDPOINT = "$CANDIDATES_API/healthcheck"

	def setup() {
		curlStub.primeWith(HEALTHCHECK_ENDPOINT, "echo dbfb025be9f97fda2052b5febcca0155")
	}

	void "should display current version of all candidates installed"() {
		given:
		def installedCandidates = [
				"gradle": "2.7",
				"groovy": "2.4.4",
				"vertx" : "3.0.0"
		]
		def allCandidates = [
				"asciidoctorj",
				"crash",
				"gaiden",
				"glide",
				"gradle",
				"grails",
				"griffon",
				"groovy",
				"groovyserv",
				"jbake",
				"jbossforge",
				"lazybones",
				"springboot",
				"vertx"
		]

		bash = blimanBashEnvBuilder
				.withOfflineMode(false)
				.withCandidates(installedCandidates.keySet().toList())
				.build()

		prepareFoldersFor(installedCandidates)

		bash.start()
		bash.execute("source $bootstrapScript")

		when:
		bash.execute('bli current')

		then:
		bash.output.contains("Using:")
		bash.output.contains("groovy: 2.4.4")
		bash.output.contains("gradle: 2.7")
		bash.output.contains("vertx: 3.0.0")
	}

	private prepareFoldersFor(Map installedCandidates) {
		installedCandidates.forEach { candidate, version ->
			def candidateVersionDirectory = "$candidatesDirectory/$candidate/$version"
			def candidateVersionBinDirectory = "$candidateVersionDirectory/bin"
			new File(candidateVersionBinDirectory).mkdirs()
			def candidateVersionPath = Paths.get(candidateVersionDirectory)
			def symlink = Paths.get("$candidatesDirectory/$candidate/current")
			createSymbolicLink(symlink, candidateVersionPath)
		}
	}
}
