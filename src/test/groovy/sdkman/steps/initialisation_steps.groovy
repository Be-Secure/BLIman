package bliman.steps

import bliman.env.BlimanBashEnvBuilder
import bliman.stubs.UnameStub

import java.util.zip.ZipException
import java.util.zip.ZipFile

import static cucumber.api.groovy.EN.And
import static bliman.stubs.WebServiceStub.primeEndpointWithString
import static bliman.stubs.WebServiceStub.primeSelfupdate

And(~'^the bliman work folder is created$') { ->
	assert blimanDir.isDirectory(), "The BLIMAN directory does not exist."
}

And(~'^the "([^"]*)" folder exists in user home$') { String arg1 ->
	assert blimanDir.isDirectory(), "The BLIMAN directory does not exist."
}

And(~'^the archive for candidate "([^"]*)" version "([^"]*)" is corrupt$') { String candidate, String version ->
	try {
		new ZipFile(new File("src/test/resources/__files/${candidate}-${version}.zip"))
		assert false, "Archive was not corrupt!"
	} catch (ZipException ze) {
		//expected behaviour
	}
}

And(~'^the archive for candidate "([^"]*)" version "([^"]*)" is removed$') { String candidate, String version ->
	def archive = new File("${blimanDir}/tmp/${candidate}-${version}.zip")
	assert !archive.exists()
}

And(~'^the bliman (.*) version "(.*)" is available for download$') { format, version ->
	primeEndpointWithString("/broker/version/bliman/${format}/stable", version)
}

And(~'^the internet is reachable$') { ->
	primeEndpointWithString("/healthcheck", "12345")
	primeSelfupdate()

	offlineMode = false
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^the internet is not reachable$') { ->
	offlineMode = false
	serviceUrlEnv = SERVICE_DOWN_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is disabled with reachable internet$') { ->
	primeEndpointWithString("/healthcheck", "12345")

	offlineMode = false
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is enabled with reachable internet$') { ->
	primeEndpointWithString("/healthcheck", "12345")

	offlineMode = true
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is enabled with unreachable internet$') { ->
	offlineMode = true
	serviceUrlEnv = SERVICE_DOWN_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^an "(.*)" machine with "(.*)" installed$') { String machine, String kernel ->
	def binFolder = "$blimanBaseDir/bin" as File
	UnameStub.prepareIn(binFolder)
			.forKernel(kernel)
			.forMachine(machine)
			.build()
}

And(~'^an initialised environment$') { ->
	bash = BlimanBashEnvBuilder.create(blimanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withScriptVersion(blimanScriptVersion)
			.withNativeVersion(blimanNativeVersion)
			.withCandidates(localCandidates)
			.build()
}

And(~'^an initialised environment without debug prints$') { ->
	bash = BlimanBashEnvBuilder.create(blimanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withScriptVersion(blimanScriptVersion)
			.withNativeVersion(blimanNativeVersion)
			.withCandidates(localCandidates)
			.withDebugMode(false)
			.build()
}

And(~'^the system is bootstrapped$') { ->
	bash.start()
	bash.execute("source $blimanDirEnv/bin/bliman-init.sh")
}

And(~'^the system is bootstrapped again$') { ->
	bash.execute("source $blimanDirEnv/bin/bliman-init.sh")
}

And(~/^the bliman scripts version is "([^"]*)"$/) { String version ->
	blimanScriptVersion = version
}

And(~/^the bliman native version is "([^"]*)"$/) { String version ->
	blimanNativeVersion = version
}

And(~/^the candidates cache is initialised with "(.*)"$/) { String candidate ->
	localCandidates << candidate
}

And(~/^a project configuration is active$/) { ->
	bash.execute("BLIMAN_ENV=" + blimanBaseEnv)
}

And(~/^a project configuration is active but points to a directory without configuration$/) { ->
	def emptyDir = tmpDir.getPath() + "/empty"
	bash.execute("mkdir $emptyDir")
	bash.execute("BLIMAN_ENV=$emptyDir")
}