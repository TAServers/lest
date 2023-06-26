local NodeType = require("src.interface.testnodetype")
local tablex = require("src.utils.tablex")
local printJSON = require("src.utils.printJSON")

local function convertPassToString(pass)
	return pass and "passed" or "failed"
end

--- Prints the test results in JSON format, similar to Jest. The point of this printer is to convey information
--- about the results that is not opinionated or specific to a particular output.
--- This makes it much easier to integrate in other applications, IDEs, etc.
---@param results lest.TestSuiteResults[]
return function(results)
	local passedTests, failedTests, totalTests, passedSuites, failedSuites, totalSuites =
		0, 0, 0, 0, 0, 0

	--- Builds a flattened list of assertion results from the Lest results.
	--- Also has a side effect of counting the number of passed and failed tests.
	---@param node lest.DescribeResults | lest.TestSuiteResults
	---@param ancestorTitles any
	local function buildAssertionResults(node, ancestorTitles)
		local assertionResults = {}

		local function cloneTitlesTable()
			local titles = {}
			for _, title in ipairs(ancestorTitles) do
				tablex.push(titles, title)
			end

			return titles
		end

		for _, childNode in ipairs(node) do
			if childNode.type == NodeType.Describe then
				local titles = cloneTitlesTable()
				tablex.push(titles, childNode.name)

				local childAssertionResults =
					buildAssertionResults(childNode, titles)

				assertionResults =
					tablex.squash(assertionResults, childAssertionResults)
			elseif childNode.type == NodeType.Test then
				local assertionResult = {
					title = childNode.name,
					status = convertPassToString(childNode.pass),
					ancestorTitles = cloneTitlesTable(),
				}

				if not childNode.pass then
					assertionResult.failureMessages =
						{ tostring(childNode.error) }
					failedTests = failedTests + 1
				else
					passedTests = passedTests + 1
				end

				totalTests = totalTests + 1
				tablex.push(assertionResults, assertionResult)
			end
		end

		return assertionResults
	end

	local report = {
		testResults = {},
	}

	for _, testSuiteNode in ipairs(results) do
		tablex.push(report.testResults, {
			assertionResults = buildAssertionResults(testSuiteNode, {}),
			status = convertPassToString(testSuiteNode.pass),
			name = testSuiteNode.name,
		})

		if not testSuiteNode.pass then
			failedSuites = failedSuites + 1
		else
			passedSuites = passedSuites + 1
		end

		totalSuites = totalSuites + 1
	end

	report.numFailedTestSuites = failedSuites
	report.numFailedTests = failedTests
	report.numPassedTestSuites = passedSuites
	report.numPassedTests = passedTests
	report.numTotalTestSuites = totalSuites
	report.numTotalTests = totalTests

	print(printJSON(report))
end
