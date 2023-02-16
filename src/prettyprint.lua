local COLORS = require("src.utils.consoleColor")
local PASS_SYMBOL = COLORS.GREEN("√")
local FAIL_SYMBOL = COLORS.RED("×")
local PASS_HEADER = COLORS.WHITE_ON_GREEN_BOLD(" PASS ")
local FAIL_HEADER = COLORS.WHITE_ON_RED_BOLD(" FAIL ")

-- Matches Jest
local TAB_SIZE = 2

local NodeType = require("src.interface.testnodetype")
local tablex = require("src.utils.tablex")

local function getTabs(amount)
	return (" "):rep(amount * TAB_SIZE)
end

--- Prints detailed reports about the test suites in the console.
---@param results lest.TestSuiteResults
local function printDetailedReports(results)
	local testSuitesPassed = {}
	for _, testSuite in pairs(results) do
		testSuitesPassed[testSuite.name] = true

		--- Recursively traverses a node.
		---@param node lest.TestNode|lest.TestSuiteResults
		local function traverseNodes(node)
			for _, childNode in ipairs(node) do
				if childNode.type == NodeType.Test and not childNode.pass then
					testSuitesPassed[testSuite.name] = false
					break
				end
			end
		end

		traverseNodes(testSuite)
	end

	--- Replicates the Jest test header output
	---@param testSuite lest.TestSuiteResults
	local function printHeader(testSuite)
		local pathComponents = {}
		for component in testSuite.name:gmatch("([^%/]*)") do
			tablex.push(pathComponents, component)
		end

		local renderedName = COLORS.DIMMED(
			table.concat(pathComponents, "/", 1, #pathComponents - 1) .. "/"
		) .. COLORS.BOLD(pathComponents[#pathComponents])

		print(
			("%s %s"):format(
				testSuitesPassed[testSuite.name] and PASS_HEADER or FAIL_HEADER,
				renderedName
			)
		)
	end

	for _, testSuite in pairs(results) do
		printHeader(testSuite)

		--- Recursively traverses a node.
		---@param node lest.TestNode|lest.TestSuiteResults
		local function traverseNodes(node, tabAmount)
			for _, childNode in ipairs(node) do
				if childNode.type == NodeType.Describe then
					print(getTabs(tabAmount) .. childNode.name)
					traverseNodes(childNode, tabAmount + 1)
				elseif childNode.type == NodeType.Test then
					print(
						("%s%s %s"):format(
							getTabs(tabAmount),
							childNode.pass and PASS_SYMBOL or FAIL_SYMBOL,
							COLORS.DIMMED(childNode.name)
						)
					)
				end
			end
		end

		traverseNodes(testSuite, 1)
	end
end

--- Pretty prints the final test results
---@param results lest.TestResults
return function(results)
	printDetailedReports(results)
end
