package bliman.specs

import bliman.support.BlimanEnvSpecification

class CompletionSpec extends BlimanEnvSpecification {
	static final String CANDIDATES_API = "http://localhost:8080/2"

	def "should complete the list of commands"() {
		given:
		bash = blimanBashEnvBuilder
				.withConfiguration("bliman_auto_complete", "true")
				.build()

		bash.start()
		bash.execute("source $bootstrapScript")

		when:
		bash.execute("COMP_CWORD=1; COMP_WORDS=(bli); _bli")
		bash.execute('echo "\${COMPREPLY[@]}"')

		then:
		bash.output.contains("install uninstall list use config default home env current upgrade version help offline selfupdate update flush")
	}

	def "should complete the list of candidates"() {
		given:
		bash = blimanBashEnvBuilder
				.withCandidates(["java", "groovy"])
				.withConfiguration("bliman_auto_complete", "true")
				.build()

		bash.start()
		bash.execute("source $bootstrapScript")

		when:
		bash.execute("COMP_CWORD=2; COMP_WORDS=(bli install); _bli")
		bash.execute('echo "\${COMPREPLY[@]}"')

		then:
		bash.output.contains("java groovy")
	}

	def "should complete the list of Java versions"() {
		given:
		curlStub.primeWith("$CANDIDATES_API/candidates/java/darwinx64/versions/all", "echo 16.0.1.hs-adpt,17.0.0-tem")

		unameStub.forKernel("Darwin").forMachine("x86_64")

		bash = blimanBashEnvBuilder
				.withConfiguration("bliman_auto_complete", "true")
				.withUnameStub(unameStub)
				.withPlatform("darwinx64")
				.build()

		bash.start()
		bash.execute("source $bootstrapScript")

		when:
		bash.execute("COMP_CWORD=3; COMP_WORDS=(bli install java); _bli")
		bash.execute('echo "\${COMPREPLY[@]}"')

		then:
		bash.output.contains("16.0.1.hs-adpt 17.0.0-tem")
	}
}
