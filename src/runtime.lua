local expect = require("src.expect")
local buildEnvironment = require("src.runtime.environment")
local tablex = require("src.utils.tablex")

local function findTests(testFiles)
	local tests = {
		beforeEach = {},
		beforeAll = {},
		afterEach = {},
		afterAll = {},
	}
	local currentDescribeScope = tests

	local function describe(name, func)
		local prevScope = currentDescribeScope
		currentDescribeScope = {
			beforeEach = {},
			beforeAll = {},
			afterEach = {},
			afterAll = {},
			name = name,
			isDescribe = true,
		}

		func()

		tablex.push(prevScope, currentDescribeScope)
		currentDescribeScope = prevScope
	end

	local function test(name, func)
		tablex.push(currentDescribeScope, {
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
			tablex.push(currentDescribeScope.beforeEach, func)
		end,
		beforeAll = function(func)
			tablex.push(currentDescribeScope.beforeAll, func)
		end,
		afterEach = function(func)
			tablex.push(currentDescribeScope.afterEach, func)
		end,
		afterAll = function(func)
			tablex.push(currentDescribeScope.afterAll, func)
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
		local function runHooks(hookTable)
			for _, hook in ipairs(hookTable) do
				hook()
			end
		end

		runHooks(testsToRun.beforeAll)

		local results = {}
		local function runTest(name, test)
			runHooks(previousBeforeEach)
			runHooks(testsToRun.beforeEach)

			local success, err = pcall(test)

			runHooks(previousAfterEach)
			runHooks(testsToRun.afterEach)

			if success then
				results[name] = { pass = true }
			else
				results[name] = { pass = false, error = err }
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
				runTest(testOrDescribe.name, testOrDescribe.func)
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
---@return table
return function(testFiles)
	local tests = findTests(testFiles)
	return runTests(tests)
end
