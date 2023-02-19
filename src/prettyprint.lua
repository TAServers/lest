local COLOURS = require("src.utils.consoleColor")
local PASS_SYMBOL = COLOURS.PASS("√")
local ERROR_SYMBOL = "●"
local FAIL_SYMBOL = COLOURS.FAIL("×")
local PASS_HEADER = COLOURS.PASS_HEADER(" PASS ")
local FAIL_HEADER = COLOURS.FAIL_HEADER(" FAIL ")

local TEST_SUITES_HEADER = "Test Suites:"
local TESTS_HEADER = "Tests:      "

-- Matches Jest
local TAB_SIZE = 2

local NodeType = require("src.interface.testnodetype")
local tablex = require("src.utils.tablex")

local function getTabs(amount)
	return (" "):rep(amount * TAB_SIZE)
end

--- Prints an indented newline-delimited block of text.
---@param spaces number
---@param block string
local function printIndentedBlock(spaces, block)
	for line in block:gmatch("([^\n]*)") do
		print((" "):rep(spaces) .. line)
	end
end

--- Recursively traverses the node tree while calling the supplied callback.
---@param node lest.TestResult|lest.DescribeResults
---@param onNode fun(node: lest.TestResult|lest.DescribeResults, depth: number):boolean A callback which is called for each Describe and Test in the tree. You can return true to keep going or return false to terminate.
---@param onEnd? fun() A callback which is called once a branch in the tree has finished being traversed.
---@param depth? number Internal parameter which is used to measure how deep the traversal is.
local function traverseNodes(node, onNode, onEnd, depth)
	depth = depth or 0

	for _, childNode in ipairs(node) do
		if onNode(childNode, depth) and childNode.type == NodeType.Describe then
			traverseNodes(childNode, onNode, onEnd, depth + 1)
		end
	end

	if onEnd then
		onEnd()
	end
end

--- Creates a colored summary element which omits certain information if it's not necessary to the reader.
---@param header string
---@param failed number
---@param passed number
---@param total number
---@return string rendered
local function createSummaryInfo(header, failed, passed, total)
	local stringTable = {}
	if failed > 0 then
		tablex.push(
			stringTable,
			COLOURS.TESTS_FAILED(("%d failed"):format(failed))
		)
	end

	if passed > 0 then
		tablex.push(
			stringTable,
			COLOURS.TESTS_PASSED(("%d passed"):format(passed))
		)
	end

	tablex.push(stringTable, ("%d total"):format(total))
	return ("%s %s"):format(
		COLOURS.BOLD(header),
		table.concat(stringTable, ", ")
	)
end

--- Prints a simple summary about the tests
---@param results lest.TestSuiteResults
local function printSummary(results)
	local passedTests, failedTests, totalTests = 0, 0, 0
	local passedSuites, failedSuites, totalSuites = 0, 0, #results

	for _, testSuite in ipairs(results) do
		if testSuite.pass then
			passedSuites = passedSuites + 1
		end

		traverseNodes(testSuite, function(node, _)
			if node.type == NodeType.Test then
				totalTests = totalTests + 1
				if node.pass then
					passedTests = passedTests + 1
				end
			end

			return true
		end)
	end

	failedSuites = totalSuites - passedSuites
	failedTests = totalTests - passedTests

	print(
		createSummaryInfo(
			TEST_SUITES_HEADER,
			failedSuites,
			passedSuites,
			totalSuites
		)
	)

	print(createSummaryInfo(TESTS_HEADER, failedTests, passedTests, totalTests))
end

--- Prints detailed error reports about the tests that failed.
---@param results lest.TestSuiteResults[]
local function printTestErrors(results)
	---@type table<number, {displayName: string, result: lest.TestResult}>
	local failedTests = {}

	---@type table<number, string>
	local parentNames = {}
	for _, testSuite in ipairs(results) do
		if not testSuite.pass then
			traverseNodes(testSuite, function(node)
				if node.type == NodeType.Describe then
					if node.pass then
						-- Skip traversing this branch as it doesn't have anything that failed.
						return false
					end

					tablex.push(parentNames, node.name)
				elseif node.type == NodeType.Test and not node.pass then
					tablex.push(failedTests, {
						displayName = table.concat(parentNames, " › ")
							.. " › "
							.. node.name,
						result = node,
					})
				end

				return true
			end, function()
				tablex.pop(parentNames)
			end)
		end
	end

	for _, failedTest in ipairs(failedTests) do
		print(
			COLOURS.ERROR_HEADER(
				string.format(" %s %s\n", ERROR_SYMBOL, failedTest.displayName)
			)
		)

		printIndentedBlock(3, tostring(failedTest.result.error))
		print()
	end
end

--- Replicates the Jest test header output
---@param testSuite lest.TestSuiteResults
local function printHeader(testSuite)
	local fileNameIndex = testSuite.name:find("/[^/]*$")
	local renderedName = COLOURS.DIMMED(testSuite.name:sub(1, fileNameIndex))
		.. COLOURS.FILENAME(testSuite.name:sub(fileNameIndex + 1))

	print(
		("%s %s"):format(
			testSuite.pass and PASS_HEADER or FAIL_HEADER,
			renderedName
		)
	)
end

--- Prints a detailed report for every test in a test suite.
---@param testSuite lest.TestSuiteResults
local function printReports(testSuite)
	traverseNodes(testSuite, function(node, depth)
		if node.type == NodeType.Describe then
			-- We add one to match how Jest formats the results
			print(getTabs(depth + 1) .. node.name)
		elseif node.type == NodeType.Test then
			print(
				("%s%s %s"):format(
					getTabs(depth + 1),
					node.pass and PASS_SYMBOL or FAIL_SYMBOL,
					COLOURS.DIMMED(node.name)
				)
			)
		end

		return true
	end)
end

--- Prints detailed reports about the test suites in the console.
---@param results lest.TestSuiteResults[]
local function printDetailedReports(results)
	local singleTestSuite = #results == 1
	for _, testSuite in ipairs(results) do
		printHeader(testSuite)
		if singleTestSuite or not testSuite.pass then
			printReports(testSuite)
		end
	end

	print()
end

--- Pretty prints the final test results
---@param results lest.TestSuiteResults[]
return function(results)
	printDetailedReports(results)
	printTestErrors(results)
	printSummary(results)
end
