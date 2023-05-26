package bliman.steps

import static cucumber.api.groovy.EN.And

And(~/^the file "([^"]+)" exists and contains "([^"]+)"$/) { String filename, String content ->
	new File(blimanBaseEnv, filename).withWriter {
		it.writeLine(content)
	}
}
