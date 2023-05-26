package bliman.steps

import com.github.tomakehurst.wiremock.client.WireMock
import bliman.support.FilesystemUtils
import bliman.support.WireMockServerProvider

import static cucumber.api.groovy.Hooks.After
import static cucumber.api.groovy.Hooks.Before

HTTP_PROXY = System.getProperty("httpProxy") ?: ""

FAKE_JDK_PATH = "/path/to/my/openjdk"
SERVICE_UP_HOST = "localhost"
SERVICE_UP_PORT = 8080
SERVICE_UP_URL = "http://$SERVICE_UP_HOST:$SERVICE_UP_PORT"
SERVICE_DOWN_URL = "http://localhost:0"

counter = "${(Math.random() * 10000).toInteger()}".padLeft(4, "0")

localGroovyCandidate = "/tmp/groovy-core" as File

blimanScriptVersion = "5.0.0"
blimanNativeVersion = "0.0.1"

blimanBaseEnv = FilesystemUtils.prepareBaseDir().absolutePath
blimanBaseDir = blimanBaseEnv as File

blimanDirEnv = "$blimanBaseEnv/.bliman"
blimanDir = blimanDirEnv as File
candidatesDir = "${blimanDirEnv}/candidates" as File
binDir = "${blimanDirEnv}/bin" as File
srcDir = "${blimanDirEnv}/src" as File
varDir = "${blimanDirEnv}/var" as File
metadataDir = "${varDir}/metadata" as File
etcDir = "${blimanDirEnv}/etc" as File
extDir = "${blimanDirEnv}/ext" as File
tmpDir = "${blimanDir}/tmp" as File

healthcheckFile = new File(varDir, "healthcheck")
candidatesFile = new File(varDir, "candidates")
versionFile = new File(varDir, "version")
initScript = new File(binDir, "bliman-init.sh")

localCandidates = ['groovy', 'grails', 'java', 'kotlin', 'scala']

bash = null

if (!binding.hasVariable("wireMock")) {
	wireMock = WireMockServerProvider.wireMockServer()
}

addShutdownHook {
	wireMock.stop()
}

Before() {
	WireMock.reset()
	cleanUp()
}

private cleanUp() {
	blimanBaseDir.deleteDir()
	localGroovyCandidate.deleteDir()
}

After() { scenario ->
	def output = bash?.output
	if (output) {
		scenario.write("\nOutput: \n${output}")
	}
	bash?.stop()
}
