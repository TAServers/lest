local expect = require("src.expect")
local buildEnvironment = require("src.runtime.environment")
local tablex = require("src.utils.tablex")
local withTimeout = require("src.utils.timeout")
local TestNodeType = require("src.interface.testnodetype")

--- Finds every test in the given files
---@param testFiles string[]
---@return lest.Tests
local function findTests(testFiles)
	---@type lest.Tests
	local tests = {}

	---@type lest.TestSuite | lest.Describe
	local currentScope

	--- Registers a new test suite
	---@param name string
	---@param func fun()
	local function describe(name, func)
		local prevScope = currentScope
		currentScope = {
			beforeEach = {},
			beforeAll = {},
			afterEach = {},
			afterAll = {},
			name = name,
			type = TestNodeType.Describe,
		}

		func()

		tablex.push(prevScope, currentScope)
		currentScope = prevScope
	end

	--- Registers a new test
	---@param name string
	---@param func fun()
	local function test(name, func)
		tablex.push(currentScope, {
			func = func,
			name = name,
			type = TestNodeType.Test,
		})
	end

	local cleanup = buildEnvironment({
		describe = describe,
		test = test,
		it = test,

		xdescribe = function() end,
		xtest = function() end,
		xit = function() end,

		beforeEach = function(func)
			tablex.push(currentScope.beforeEach, func)
		end,
		beforeAll = function(func)
			tablex.push(currentScope.beforeAll, func)
		end,
		afterEach = function(func)
			tablex.push(currentScope.afterEach, func)
		end,
		afterAll = function(func)
			tablex.push(currentScope.afterAll, func)
		end,
	})

	for _, filepath in ipairs(testFiles) do
		currentScope = {
			beforeAll = {},
			beforeEach = {},
			afterAll = {},
			afterEach = {},
			name = filepath,
			type = TestNodeType.Suite,
		}

		dofile(filepath)

		tablex.push(tests, currentScope)
	end

	cleanup()

	return tests
end

--- Runs all registered tests
---@param tests lest.Tests
---@return boolean success
---@return lest.TestResults results
local function runTests(tests)
	local allTestsPassed = true

	--- Internal test runner
	---@param testsToRun lest.TestSuite | lest.Describe
	---@param previousBeforeEach fun()[]
	---@param previousAfterEach fun()[]
	---@return lest.TestResults
	local function _runTests(testsToRun, previousBeforeEach, previousAfterEach)
		--- Helper to run hooks
		---@param hookTable fun()[]
		local function runHooks(hookTable)
			for _, hook in ipairs(hookTable) do
				local success, err = withTimeout(5, hook)
				if not success then
					error(err)
				end
			end
		end

		runHooks(testsToRun.beforeAll)

		local results = {}

		--- Helper to run a single test
		---@param test lest.Test
		local function runTest(test)
			runHooks(previousBeforeEach)
			runHooks(testsToRun.beforeEach)

			local success, err = withTimeout(5, test.func)

			runHooks(previousAfterEach)
			runHooks(testsToRun.afterEach)

			if success then
				results[test.name] = { pass = true }
			else
				allTestsPassed = false
				results[test.name] = { pass = false, error = err }
			end
		end

		for _, testOrDescribe in ipairs(testsToRun) do
			if testOrDescribe.type == TestNodeType.Describe then
				results[testOrDescribe.name] = _runTests(
					testOrDescribe,
					tablex.squash(previousBeforeEach, testsToRun.beforeEach),
					tablex.squash(previousAfterEach, testsToRun.afterEach)
				)
			else
				runTest(testOrDescribe --[[@as lest.Test]]) -- LuaLS does not narrow by isDescribe
			end
		end

		runHooks(testsToRun.afterAll)

		return results
	end

	local cleanup = buildEnvironment({
		expect = expect,
	})

	local results = {}
	for _, testSuite in ipairs(tests) do
		results[testSuite.name] = _runTests(testSuite, {}, {})
	end

	cleanup()

	return allTestsPassed, results
end

return { findTests = findTests, runTests = runTests }
