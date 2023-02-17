local COLOURS = require("src.utils.consoleColor")
local PASS_SYMBOL = COLOURS.PASS("√")
local ERROR_SYMBOL = "●"
local FAIL_SYMBOL = COLOURS.FAIL("×")
local PASS_HEADER = COLOURS.PASS_HEADER(" PASS ")
local FAIL_HEADER = COLOURS.FAIL_HEADER(" FAIL ")

-- Matches Jest
local TAB_SIZE = 2

local NodeType = require("src.interface.testnodetype")
local tablex = require("src.utils.tablex")
local prettyValue = require("src.utils.prettyValue")

local function getTabs(amount)
	return (" "):rep(amount * TAB_SIZE)
end

--- Recursively traverses the node tree while calling the supplied callback.
---@param node lest.TestResult|lest.Describe
---@param onNode fun(node: lest.TestResult|lest.Describe, depth: number):boolean A callback which is called for each Describe and Test in the tree. You can return true to keep going or return false to terminate.
---@param onEnd fun()|nil A callback which is called once a branch in the tree has finished being traversed.
local function traverseNodes(node, onNode, onEnd, _depth)
	_depth = _depth or 0

	for _, childNode in ipairs(node) do
		if childNode.type == NodeType.Describe then
			if not onNode(childNode, _depth) then
				break -- Callback wants to terminate
			end

			traverseNodes(childNode, onNode, onEnd, _depth + 1)
		elseif childNode.type == NodeType.Test then
			if not onNode(childNode, _depth) then
				break -- Callback wants to terminate
			end
		end
	end

	if onEnd then
		onEnd()
	end
end

--- Prints a simple summary about the tests
---@param results lest.TestResults
---@param testSuitesPassed table<string, boolean>
local function printSummary(results, testSuitesPassed)
	local passedTests, failedTests, totalTests = 0, 0, 0
	local passedSuites, failedSuites, totalSuites = 0, 0, #results

	for _, passed in pairs(testSuitesPassed) do
		if passed then
			passedSuites = passedSuites + 1
		else
			failedSuites = failedSuites + 1
		end
	end

	for _, testSuite in ipairs(results) do
		traverseNodes(testSuite, function(node, _)
			if node.type == NodeType.Test then
				totalTests = totalTests + 1
				if node.pass then
					passedTests = passedTests + 1
				else
					failedTests = failedTests + 1
				end
			end

			return true
		end)
	end

	-- Certain elements are omitted in Jest depending if they are vital to conveying information or not.
	local testSuitesStrTbl = {}
	if failedSuites > 0 then
		tablex.push(
			testSuitesStrTbl,
			COLOURS.TESTS_FAILED(("%d failed"):format(failedSuites))
		)
	end

	if passedSuites > 0 then
		tablex.push(
			testSuitesStrTbl,
			COLOURS.TESTS_PASSED(("%d passed"):format(passedSuites))
		)
	end

	tablex.push(testSuitesStrTbl, ("%d total"):format(totalSuites))
	local testSuitesRendered = ("%s %s"):format(
		COLOURS.BOLD("Test Suites:"),
		table.concat(testSuitesStrTbl, ", ")
	)

	-- TODO: Figure out a way to de-duplicate this code neatly
	local testsStrTbl = {}
	if failedTests > 0 then
		tablex.push(
			testsStrTbl,
			COLOURS.TESTS_FAILED(("%d failed"):format(failedTests))
		)
	end

	if passedTests > 0 then
		tablex.push(
			testsStrTbl,
			COLOURS.TESTS_PASSED(("%d passed"):format(passedTests))
		)
	end

	tablex.push(testsStrTbl, ("%d total"):format(totalTests))
	local testsRendered = ("%s %s"):format(
		COLOURS.BOLD("Tests:"),
		table.concat(testsStrTbl, ", ")
	)

	print(testSuitesRendered)
	print(testsRendered)
end

--- Prints detailed error reports about the tests that failed.
---@param results lest.TestResults
local function printTestErrors(results)
	---@type table<number, {displayName: string, result: lest.TestResult}>
	local failedTests = {}

	local currentDescribeHierarchy = {}
	for _, testSuite in ipairs(results) do
		traverseNodes(testSuite, function(node)
			if node.type == NodeType.Describe then
				tablex.push(currentDescribeHierarchy, node.name)
			elseif node.type == NodeType.Test then
				if not node.pass then
					tablex.push(failedTests, {
						displayName = table.concat(
							currentDescribeHierarchy,
							" › "
						) .. " › " .. node.name,
						result = node,
					})
				end
			end

			return true
		end, function()
			tablex.pop(currentDescribeHierarchy)
		end)
	end

	for _, failedTest in ipairs(failedTests) do
		print(
			COLOURS.ERROR_HEADER(
				string.format(" %s %s\n", ERROR_SYMBOL, failedTest.displayName)
			)
		)

		if type(failedTest.result.error) == "table" then
			if failedTest.result.error.signature then
				print("   " .. failedTest.result.error.signature .. "\n")
			end
		else
			print("   " .. prettyValue(failedTest.result.error) .. "\n")
		end
	end
end

--- Prints detailed reports about the test suites in the console.
---@param results lest.TestResults
---@param testSuitesPassed table<string, boolean> Table containg which test suites passed
local function printDetailedReports(results, testSuitesPassed)
	--- Replicates the Jest test header output
	---@param testSuite lest.TestSuiteResults
	local function printHeader(testSuite)
		local pathComponents = {}
		for component in testSuite.name:gmatch("([^%/]*)") do
			tablex.push(pathComponents, component)
		end

		local renderedName = COLOURS.DIMMED(
			table.concat(pathComponents, "/", 1, #pathComponents - 1) .. "/"
		) .. COLOURS.FILENAME(pathComponents[#pathComponents])

		print(
			("%s %s"):format(
				testSuitesPassed[testSuite.name] and PASS_HEADER or FAIL_HEADER,
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

		print("\n")
	end

	local singleTestSuite = #results == 1
	for _, testSuite in ipairs(results) do
		printHeader(testSuite)
		if singleTestSuite or not testSuitesPassed[testSuite.name] then
			printReports(testSuite)
		end
	end

	print("\n")
end

--- Pretty prints the final test results
---@param results lest.TestResults
return function(results)
	---@type table<string, boolean>
	local testSuitesPassed = {}
	for _, testSuite in ipairs(results) do
		testSuitesPassed[testSuite.name] = true

		traverseNodes(testSuite, function(node, _)
			if node.type == NodeType.Test and not node.pass then
				testSuitesPassed[testSuite.name] = false
				return false -- Terminate early
			end

			return true
		end)
	end

	printDetailedReports(results, testSuitesPassed)
	printTestErrors(results)
	printSummary(results, testSuitesPassed)
end
