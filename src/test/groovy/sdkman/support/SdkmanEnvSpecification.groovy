package bliman.support

import bliman.env.BlimanBashEnvBuilder
import bliman.stubs.CurlStub
import bliman.stubs.UnameStub

import static bliman.support.FilesystemUtils.prepareBaseDir

abstract class BlimanEnvSpecification extends BashEnvSpecification {

	BlimanBashEnvBuilder blimanBashEnvBuilder

	CurlStub curlStub
	UnameStub unameStub

	File blimanBaseDirectory
	File blimanDotDirectory
	File candidatesDirectory

	String bootstrapScript

	def setup() {
		blimanBaseDirectory = prepareBaseDir()
		curlStub = CurlStub.prepareIn(new File(blimanBaseDirectory, "bin"))
		unameStub = UnameStub.prepareIn(new File(blimanBaseDirectory, "bin"))
		blimanBashEnvBuilder = BlimanBashEnvBuilder
				.create(blimanBaseDirectory)
				.withUnameStub(unameStub)
				.withCurlStub(curlStub)

		blimanDotDirectory = new File(blimanBaseDirectory, ".bliman")
		candidatesDirectory = new File(blimanDotDirectory, "candidates")
		bootstrapScript = "${blimanDotDirectory}/bin/bliman-init.sh"
	}

	def cleanup() {
		assert blimanBaseDirectory.deleteDir()
	}
}
