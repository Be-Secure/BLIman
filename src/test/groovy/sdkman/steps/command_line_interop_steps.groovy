package bliman.steps

import static cucumber.api.groovy.EN.And

And(~'^I enter \"([^\"]*)\"$') { String command ->
	bash.execute(command)
	result = bash.output
}

And(~'^I enter "([^"]*)" and answer "([^"]*)"$') { String command, String answer ->
	bash.execute(command, [answer])
	result = bash.output
}

And(~'^I see \"([^\"]*)\"$') { String output ->
	assert result.contains(output)
}

And(~'^I do not see "([^"]*)"$') { String output ->
	assert !result.contains(output)
}

And(~'^I see only \"([^\"]*)\"$') { String output ->
	assert result?.replaceAll("\\n", "") == output
}

And(~'^I see the current bliman version$') { ->
	assert result.contains("BLIMAN")
}

And(~'^I see a single occurrence of \"([^\"]*)\"$') { String occurrence ->
	assert result.count(occurrence) == 1
}

And(~'^I see no occurrences of \"([^\"]*)\"$') { String occurrence ->
	assert result.count(occurrence) == 0
}

And(~'the "(.*)" variable contains "(.*)"') { String home, String segment ->
	bash.execute("echo \$$home")
	assert bash.output.contains(segment)
}

And(~'the "(.*)" variable is not set') { String home ->
	bash.execute("echo \$$home")
	assert !bash.output.contains(".bliman/")
}

And(~'^the home path ends with \"([^\"]*)\"$') { String suffix ->
	def path = blimanBaseDir.absolutePath + "/" + suffix
	assert result.trim().endsWith(path)
}
