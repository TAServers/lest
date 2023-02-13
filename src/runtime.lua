local expect = require("src.expect")
local buildEnvironment = require("src.runtime.environment")
local tablex = require("src.utils.tablex")

--- Finds every test in the given files
---@param testFiles string[]
---@return lest.TestSuite
local function findTests(testFiles)
	---@type lest.TestSuite
	local tests = {
		beforeEach = {},
		beforeAll = {},
		afterEach = {},
		afterAll = {},
	}

	---@type lest.TestSuite | lest.Describe
	local currentScope = tests

	local function describe(name, func)
		local prevScope = currentScope
		currentScope = {
			beforeEach = {},
			beforeAll = {},
			afterEach = {},
			afterAll = {},
			name = name,
			isDescribe = true,
		}

		func()

		tablex.push(prevScope, currentScope)
		currentScope = prevScope
	end

	--- Registeres a new test
	---@param name string
	---@param func fun()
	local function test(name, func)
		tablex.push(currentScope, {
			func = func,
			name = name,
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
		dofile(filepath)
	end

	cleanup()

	return tests
end

--- Runs all registered tests
---@param tests lest.TestSuite
---@return lest.TestResults
local function runTests(tests)
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
				hook()
			end
		end

		runHooks(testsToRun.beforeAll)

		local results = {}

		--- Helper to run a single test
		---@param test lest.Test
		local function runTest(test)
			runHooks(previousBeforeEach)
			runHooks(testsToRun.beforeEach)

			local success, err = pcall(test.func)

			runHooks(previousAfterEach)
			runHooks(testsToRun.afterEach)

			if success then
				results[test.name] = { pass = true }
			else
				results[test.name] = { pass = false, error = err }
			end
		end

		for _, testOrDescribe in ipairs(testsToRun) do
			if testOrDescribe.isDescribe then
				results[testOrDescribe.name] = _runTests(
					testOrDescribe,
					tablex.merge(previousBeforeEach, testsToRun.beforeEach),
					tablex.merge(previousAfterEach, testsToRun.afterEach)
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

	local results = _runTests(tests, {}, {})

	cleanup()

	return results
end

--- Start a test runtime
---@param testFiles string[]
---@return lest.TestResults
return function(testFiles)
	local tests = findTests(testFiles)
	return runTests(tests)
end
