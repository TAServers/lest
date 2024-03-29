local expect = require("src.lua.expect")
local buildEnvironment = require("src.lua.runtime.environment")
local tablex = require("src.lua.utils.tablex")
local withTimeout = require("src.lua.utils.timeout")
local NodeType = require("src.lua.interface.testnodetype")
local assertType = require("src.lua.asserts.type")
local unpack = require("src.lua.utils.unpack")

lest = lest or {}

local defaultTimeoutSeconds = 5
local currentTimeoutSeconds = defaultTimeoutSeconds

--- Sets the timeout used by default
---@param timeout number
local function setDefaultTimeout(timeout)
	assertType(timeout, "number")
	defaultTimeoutSeconds = timeout / 1000
end

--- Sets the timeout for all hooks and tests in this suite
---@param timeout number
---@diagnostic disable-next-line: duplicate-set-field
function lest.setTimeout(timeout)
	assertType(timeout, "number")
	currentTimeoutSeconds = timeout / 1000
end

--- Finds every test in the given files
---@param testFiles string[]
---@return lest.TestSuite[]
local function findTests(testFiles)
	assertType(testFiles, "table")

	---@type lest.TestSuite[]
	local tests = {}

	---@type lest.TestSuite | lest.Describe
	local currentScope

	local function runInDescribeScope(name, func)
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
	local function registerTest(name, func, timeout)
		tablex.push(currentScope, {
			func = func,
			name = name,
			type = NodeType.Test,
			timeout = timeout and (timeout / 1000) or currentTimeoutSeconds,
		})
	end

	local disabledDescribeOrTest = setmetatable({
		each = function()
			return function() end
		end,
	}, { __call = function() end })

	--- Registers a new test group
	---@class lest.DescribeFunction
	---@field each fun(testCases: table): fun(name: string, func: fun(...: any))
	---@overload fun(name: string, func: fun())
	local describe = {}
	describe.__index = describe
	describe.skip = disabledDescribeOrTest

	function describe:__call(name, func)
		runInDescribeScope(name, func)
	end

	--- Generates describe blocks for each value in the array
	---@param testCases table
	---@return fun(name: string, func: fun(...: any))
	function describe.each(testCases)
		return function(name, func)
			for _, testCase in ipairs(testCases) do
				if type(testCase) ~= "table" then
					testCase = { testCase }
				end

				local caseName = string.format(name, unpack(testCase))
				runInDescribeScope(caseName, function()
					func(unpack(testCase))
				end)
			end
		end
	end

	--- Registers a new test group
	---@class lest.TestFunction
	---@field each fun(testCases: table): fun(name: string, func: fun(...: any), timeout: number)
	---@overload fun(name: string, func: fun())
	local test = {}
	test.__index = test
	test.skip = disabledDescribeOrTest

	function test:__call(name, func, timeout)
		registerTest(name, func, timeout)
	end

	--- Generates test cases for each value in the array
	---@param testCases table
	---@return fun(name: string, func: fun(...: any), timeout: number)
	function test.each(testCases)
		return function(name, func, timeout)
			for _, testCase in ipairs(testCases) do
				if type(testCase) ~= "table" then
					testCase = { testCase }
				end

				local caseName = string.format(name, unpack(testCase))
				registerTest(caseName, function()
					func(unpack(testCase))
				end, timeout)
			end
		end
	end

	--- Makes a new hook register function
	---@param key "beforeEach" | "beforeAll" | "afterEach" | "afterAll"
	---@return fun(func: fun(), timeout: number)
	local function makeHook(key)
		return function(func, timeout)
			tablex.push(currentScope[key], {
				func = func,
				timeout = timeout and (timeout / 1000) or currentTimeoutSeconds,
			})
		end
	end

	local cleanup = buildEnvironment({
		describe = setmetatable({}, describe),
		test = setmetatable({}, test),
		it = setmetatable({}, test),

		xdescribe = disabledDescribeOrTest,
		xtest = disabledDescribeOrTest,
		xit = disabledDescribeOrTest,

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
		currentTimeoutSeconds = defaultTimeoutSeconds

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
	assertType(tests, "table")

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
		---@return lest.TestResult result
		local function runTest(test)
			runHooks(previousBeforeEach)
			runHooks(testsToRun.beforeEach)

			local success, err = withTimeout(test.timeout, test.func)

			runHooks(previousAfterEach)
			runHooks(testsToRun.afterEach)

			if success then
				return {
					type = NodeType.Test,
					name = test.name,
					pass = true,
				}
			else
				allTestsPassed = false
				return {
					type = NodeType.Test,
					name = test.name,
					pass = false,
					error = err,
				}
			end
		end

		results.pass = true

		for _, testOrDescribe in ipairs(testsToRun) do
			---@type lest.DescribeResults|lest.TestResult
			local result

			if testOrDescribe.type == NodeType.Describe then
				result = _runTests(
					testOrDescribe,
					tablex.squash(previousBeforeEach, testsToRun.beforeEach),
					tablex.squash(previousAfterEach, testsToRun.afterEach)
				)
			else
				result = runTest(testOrDescribe --[[@as lest.Test]]) -- LuaLS does not narrow by isDescribe
			end

			tablex.push(results, result)

			if not result.pass then
				results.pass = false
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
		lest.removeAllModuleMocks()
	end

	cleanup()

	return allTestsPassed, results
end

return {
	findTests = findTests,
	runTests = runTests,
	setDefaultTimeout = setDefaultTimeout,
}
