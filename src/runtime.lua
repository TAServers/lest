local expect = require("src.expect")
local buildEnvironment = require("src.runtime.environment")
local mergeTables = require("src.utils.mergeTables")

local HookKey = {
	BeforeEach = 0,
	BeforeAll = 1,
	AfterEach = 2,
	AfterAll = 3,
}

local function findTests(testFiles)
	local tests = {
		[HookKey.BeforeEach] = {},
		[HookKey.BeforeAll] = {},
		[HookKey.AfterEach] = {},
		[HookKey.AfterAll] = {},
	}
	local currentDescribeScope = tests

	local function describe(name, func)
		local prevScope = currentDescribeScope
		currentDescribeScope = {
			[HookKey.BeforeEach] = {},
			[HookKey.BeforeAll] = {},
			[HookKey.AfterEach] = {},
			[HookKey.AfterAll] = {},
		}

		func()

		prevScope[name] = currentDescribeScope
		currentDescribeScope = prevScope
	end

	local function test(name, func)
		currentDescribeScope[name] = func
	end

	local cleanup = buildEnvironment({
		describe = describe,
		test = test,
		it = test,

		xdescribe = function() end,
		xtest = function() end,
		xit = function() end,

		beforeEach = function(func)
			currentDescribeScope[HookKey.BeforeEach][#currentDescribeScope[HookKey.BeforeEach] + 1] =
				func
		end,
		beforeAll = function(func)
			currentDescribeScope[HookKey.BeforeAll][#currentDescribeScope[HookKey.BeforeAll] + 1] =
				func
		end,
		afterEach = function(func)
			currentDescribeScope[HookKey.AfterEach][#currentDescribeScope[HookKey.AfterEach] + 1] =
				func
		end,
		afterAll = function(func)
			currentDescribeScope[HookKey.AfterAll][#currentDescribeScope[HookKey.AfterAll] + 1] =
				func
		end,
	})

	for _, filepath in ipairs(testFiles) do
		dofile(filepath)
	end

	cleanup()

	return tests
end

--- Runs all registered tests
---@param tests table<string, table | function>
---@return table
local function runTests(tests)
	local function _runTests(testsToRun, previousBeforeEach, previousAfterEach)
		local function runHooks(hookKeyOrTable)
			for _, hook in
				ipairs(
					type(hookKeyOrTable) == "table" and hookKeyOrTable
						or testsToRun[hookKeyOrTable]
				)
			do
				hook()
			end
		end

		runHooks(HookKey.BeforeAll)

		local results = {}
		local function runTest(name, test)
			runHooks(previousBeforeEach)
			runHooks(HookKey.BeforeEach)

			local success, err = pcall(test)

			runHooks(previousAfterEach)
			runHooks(HookKey.AfterEach)

			if success then
				results[name] = { pass = true }
			else
				results[name] = { pass = false, error = err }
			end
		end

		for name, testOrDescribe in pairs(testsToRun) do
			if type(name) == "string" then
				if type(testOrDescribe) == "table" then
					results[name] = _runTests(
						testOrDescribe,
						mergeTables(
							previousBeforeEach,
							testsToRun[HookKey.BeforeEach]
						),
						mergeTables(
							previousAfterEach,
							testsToRun[HookKey.AfterEach]
						)
					)
				else
					runTest(name, testOrDescribe)
				end
			end
		end

		runHooks(HookKey.AfterAll)

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
---@return table
return function(testFiles)
	local tests = findTests(testFiles)
	return runTests(tests)
end
