local expect = require("src.expect")
local buildEnvironment = require("src.runtime.environment")

local function findTests(testFiles)
	local tests = {}
	local currentDescribeScope = tests

	local function describe(name, func)
		local prevScope = currentDescribeScope
		currentDescribeScope = {}

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
	local function _runTests(testsToRun)
		local results = {}

		for name, testOrDescribe in pairs(testsToRun) do
			if type(testOrDescribe) == "table" then
				results[name] = _runTests(testOrDescribe)
			else
				local success, err = pcall(testOrDescribe)
				if success then
					results[name] = { pass = true }
				else
					results[name] = { pass = false, error = err }
				end
			end
		end

		return results
	end

	local cleanup = buildEnvironment({
		expect = expect,
	})

	local results = _runTests(tests)

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
