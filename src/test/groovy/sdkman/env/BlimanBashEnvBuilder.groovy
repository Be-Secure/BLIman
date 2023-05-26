package bliman.env

import groovy.transform.ToString
import bliman.stubs.CurlStub
import bliman.stubs.UnameStub
import bliman.support.UnixUtils

@ToString(includeNames = true)
class BlimanBashEnvBuilder {

	final BUILD_STAGE_DIR = "build/stage/bliman-latest+hashme"
	final BUILD_BIN_DIR = "$BUILD_STAGE_DIR/bin"
	final BUILD_SRC_DIR = "$BUILD_STAGE_DIR/src"
	final BUILD_COMPLETION_DIR = "$BUILD_STAGE_DIR/contrib/completion/bash"

	//mandatory fields
	private final File baseFolder

	//optional fields with sensible defaults
	private Optional<CurlStub> curlStub = Optional.empty()
	private Optional<UnameStub> unameStub = Optional.empty()
	private List candidates = ['groovy', 'grails', 'java']
	private String platform = UnixUtils.inferPlatform()
	private boolean offlineMode = false
	private String candidatesApi = "http://localhost:8080/2"
	private String jdkHome = "/path/to/my/jdk"
	private String httpProxy
	private String scriptVersion
	private String nativeVersion
	private boolean debugMode = true

	Map config = [
			bliman_auto_answer : 'false',
			bliman_beta_channel: 'false',
			bliman_selfupdate_feature: 'true'
	]

	File blimanDir, blimanBinDir, blimanVarDir, blimanSrcDir, blimanEtcDir, blimanExtDir,
		 blimanTmpDir, blimanCandidatesDir, blimanMetadataDir, blimanContribDir
	
	static BlimanBashEnvBuilder create(File baseFolder) {
		new BlimanBashEnvBuilder(baseFolder)
	}

	private BlimanBashEnvBuilder(File baseFolder) {
		this.baseFolder = baseFolder
	}

	BlimanBashEnvBuilder withCurlStub(CurlStub curlStub) {
		this.curlStub = Optional.of(curlStub)
		this
	}

	BlimanBashEnvBuilder withUnameStub(UnameStub unameStub) {
		this.unameStub = Optional.of(unameStub)
		this
	}
	
	BlimanBashEnvBuilder withPlatform(String platform) {
		this.platform = platform
		this
	}

	BlimanBashEnvBuilder withCandidates(List candidates) {
		this.candidates = candidates
		this
	}

	BlimanBashEnvBuilder withConfiguration(String key, String value) {
		config.put key, value
		this
	}

	BlimanBashEnvBuilder withOfflineMode(boolean offlineMode) {
		this.offlineMode = offlineMode
		this
	}

	BlimanBashEnvBuilder withCandidatesApi(String service) {
		this.candidatesApi = service
		this
	}

	BlimanBashEnvBuilder withJdkHome(String jdkHome) {
		this.jdkHome = jdkHome
		this
	}

	BlimanBashEnvBuilder withHttpProxy(String httpProxy) {
		this.httpProxy = httpProxy
		this
	}

	BlimanBashEnvBuilder withScriptVersion(String version) {
		this.scriptVersion = version
		this
	}

	BlimanBashEnvBuilder withNativeVersion(String version) {
		this.nativeVersion = version
		this
	}

	BlimanBashEnvBuilder withDebugMode(boolean debugMode) {
		this.debugMode = debugMode
		this
	}

	BashEnv build() {
		blimanDir = prepareDirectory(baseFolder, ".bliman")
		blimanBinDir = prepareDirectory(blimanDir, "bin")
		blimanVarDir = prepareDirectory(blimanDir, "var")
		blimanSrcDir = prepareDirectory(blimanDir, "src")
		blimanEtcDir = prepareDirectory(blimanDir, "etc")
		blimanExtDir = prepareDirectory(blimanDir, "ext")
		blimanTmpDir = prepareDirectory(blimanDir, "tmp")
		blimanCandidatesDir = prepareDirectory(blimanDir, "candidates")
		blimanMetadataDir = prepareDirectory(blimanVarDir, "metadata")
		blimanContribDir = prepareDirectory(blimanDir, "contrib")

		curlStub.map { it.build() }
		unameStub.map { it.build() }

		initializeConfiguration(blimanEtcDir, config)
		initializeCandidates(blimanCandidatesDir, candidates)
		initializeCandidatesCache(blimanVarDir, candidates)
		initializePlatformDescriptor(blimanVarDir, platform)
		initializeScriptVersionFile(blimanVarDir, scriptVersion)
		initializeNativeVersionFile(blimanVarDir, nativeVersion)

		primeInitScript(blimanBinDir)
		primeModuleScripts(blimanSrcDir)
		primeBashCompletionScript(blimanContribDir)

		def env = [
				BLIMAN_DIR           : blimanDir.absolutePath,
				BLIMAN_CANDIDATES_DIR: blimanCandidatesDir.absolutePath,
				BLIMAN_OFFLINE_MODE  : "$offlineMode",
				BLIMAN_CANDIDATES_API: candidatesApi,
				bliman_debug_mode    : Boolean.toString(debugMode),
				JAVA_HOME            : jdkHome
		]

		if (httpProxy) {
			env.put("http_proxy", httpProxy)
		}

		new BashEnv(baseFolder.absolutePath, env)
	}

	private prepareDirectory(File target, String directoryName) {
		def directory = new File(target, directoryName)
		directory.mkdirs()
		directory
	}

	private initializeScriptVersionFile(File folder, String version) {
		if (version) {
			new File(folder, "version") << version
		}
	}

	private initializeNativeVersionFile(File folder, String version) {
		if (version) {
			new File(folder, "version_native") << version
		}
	}

	private initializeCandidates(File folder, List candidates) {
		candidates.each { candidate ->
			new File(folder, candidate).mkdirs()
		}
	}

	private initializeCandidatesCache(File folder, List candidates) {
		def candidatesCache = new File(folder, "candidates")
		if (candidates) {
			candidatesCache << candidates.join(",")
		} else {
			candidatesCache << ""
		}
	}
	
	private initializePlatformDescriptor(File folder, String platform) {
		def platformDescriptor = new File(folder, "platform")
		platformDescriptor << platform
	}

	private initializeConfiguration(File targetFolder, Map config) {
		def configFile = new File(targetFolder, "config")
		config.each { key, value ->
			configFile << "$key=$value\n"
		}
	}

	private primeInitScript(File targetFolder) {
		def sourceInitScript = new File(BUILD_BIN_DIR, 'bliman-init.sh')

		if (!sourceInitScript.exists())
			throw new IllegalStateException("bliman-init.sh has not been prepared for consumption.")

		def destInitScript = new File(targetFolder, "bliman-init.sh")
		destInitScript << sourceInitScript.text
		destInitScript
	}

	private primeBashCompletionScript(File targetFolder) {
		def sourceCompletionScript = new File(BUILD_COMPLETION_DIR, 'sdk')

		if (!sourceCompletionScript.exists())
			throw new IllegalStateException("bli has not been prepared for consumption.")

		new FileTreeBuilder(targetFolder).with {
			completion {
				bash {
					sdk(sourceCompletionScript.text)
				}
			}			
		}
	}

	private primeModuleScripts(File targetFolder) {
		for (f in new File(BUILD_SRC_DIR).listFiles()) {
			if (!(f.name in ['selfupdate.sh', 'install.sh', 'bliman-init.sh'])) {
				new File(targetFolder, f.name) << f.text
			}
		}
	}
}
