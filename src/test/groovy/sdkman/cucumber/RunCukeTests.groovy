package bliman.cucumber

import io.cucumber.junit.Cucumber
import io.cucumber.junit.CucumberOptions
import org.junit.runner.RunWith

@RunWith(Cucumber)
@CucumberOptions(
		strict = true,
		features = ["src/test/resources/features"],
		glue = ["bliman.steps"],
		tags = ["not @manual", "not @review"]
)
class RunCukeTests {}
