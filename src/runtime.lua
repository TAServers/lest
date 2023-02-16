local expect = require("src.expect")
local buildEnvironment = require("src.runtime.environment")
local tablex = require("src.utils.tablex")
local withTimeout = require("src.utils.timeout")
local NodeType = require("src.interface.testnodetype")

local DEFAULT_TIMEOUT_SECONDS = 5

--- Finds every test in the given files
---@param testFiles string[]
---@return lest.TestSuite[]
local function findTests(testFiles)
	---@type lest.TestSuite[]
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
			type = NodeType.Describe,
		}

		func()

		tablex.push(prevScope, currentScope)
		currentScope = prevScope
	end

	--- Registers a new test
	---@param name string
	---@param func fun()
	---@param timeout number
	local function test(name, func, timeout)
		tablex.push(currentScope, {
			func = func,
			name = name,
			type = NodeType.Test,
			timeout = timeout and (timeout / 1000) or DEFAULT_TIMEOUT_SECONDS,
		})
	end

	--- Makes a new hook register function
	---@param key "beforeEach" | "beforeAll" | "afterEach" | "afterAll"
	---@return fun(func: fun(), timeout: number)
	local function makeHook(key)
		return function(func, timeout)
			tablex.push(currentScope[key], {
				func = func,
				timeout = timeout and (timeout / 1000)
					or DEFAULT_TIMEOUT_SECONDS,
			})
		end
	end

	local cleanup = buildEnvironment({
		describe = describe,
		test = test,
		it = test,

		xdescribe = function() end,
		xtest = function() end,
		xit = function() end,

		beforeEach = makeHook("beforeEach"),
		beforeAll = makeHook("beforeAll"),
		afterEach = makeHook("afterEach"),
		afterAll = makeHook("afterAll"),
	})

	for _, filepath in ipairs(testFiles) do
		currentScope = {
			beforeAll = {},
			beforeEach = {},
			afterAll = {},
			afterEach = {},
			name = filepath,
			type = NodeType.Suite,
		}

		dofile(filepath)

		tablex.push(tests, currentScope)
	end

	cleanup()

	return tests
end

--- Runs all registered tests
---@param tests lest.TestSuite[]
---@return boolean success
---@return lest.TestSuiteResults[] results
local function runTests(tests)
	local allTestsPassed = true

	--- Internal test runner
	---@param testsToRun lest.TestSuite | lest.Describe
	---@param previousBeforeEach lest.Hook[]
	---@param previousAfterEach lest.Hook[]
	---@return lest.TestSuiteResults | lest.DescribeResults
	local function _runTests(testsToRun, previousBeforeEach, previousAfterEach)
		--- Helper to run hooks
		---@param hookTable lest.Hook[]
		local function runHooks(hookTable)
			for _, hook in ipairs(hookTable) do
				local success, err = withTimeout(hook.timeout, hook.func)
				if not success then
					error(err)
				end
			end
		end

		runHooks(testsToRun.beforeAll)

		---@type lest.TestSuiteResults | lest.DescribeResults
		local results = {}

		--- Helper to run a single test
		---@param test lest.Test
		local function runTest(test)
			runHooks(previousBeforeEach)
			runHooks(testsToRun.beforeEach)

			local success, err = withTimeout(test.timeout, test.func)

			runHooks(previousAfterEach)
			runHooks(testsToRun.afterEach)

			if success then
				tablex.push(results, {
					type = NodeType.Test,
					name = test.name,
					pass = true,
				})
			else
				allTestsPassed = false
				tablex.push(results, {
					type = NodeType.Test,
					name = test.name,
					pass = false,
					error = err,
				})
			end
		end

		for _, testOrDescribe in ipairs(testsToRun) do
			if testOrDescribe.type == NodeType.Describe then
				tablex.push(
					results,
					_runTests(
						testOrDescribe,
						tablex.squash(previousBeforeEach, testsToRun.beforeEach),
						tablex.squash(previousAfterEach, testsToRun.afterEach)
					)
				)
			else
				runTest(testOrDescribe --[[@as lest.Test]]) -- LuaLS does not narrow by isDescribe
			end
		end

		runHooks(testsToRun.afterAll)

		results.type = testsToRun.type
		results.name = testsToRun.name
		return results
	end

	local cleanup = buildEnvironment({
		expect = expect,
	})

	local results = {}
	for _, testSuite in ipairs(tests) do
		tablex.push(results, _runTests(testSuite, {}, {}))
	end

	cleanup()

	return allTestsPassed, results
end

return { findTests = findTests, runTests = runTests }
