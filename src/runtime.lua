local printTable = require("src.utils.printTable")
local expect = require("src.expect")

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

local function createEnvironment()
	local function __index(self, key)
		return _G[key]
	end

	return setmetatable({
		expect = expect,

		describe = describe,
		test = test,
		it = test,

		xdescribe = function() end,
		xtest = function() end,
		xit = function() end,
	}, {
		__index,
	})
end

local function getTestsForFile(filepath, environment)
	local func, err = loadfile(filepath, "t", environment)

	if err then
		error(err)
	end

	if not func then
		error("Failed to load test file " .. filepath)
	end

	func()
end

--- Start a test runtime
---@param testFiles string[]
return function(testFiles)
	local environment = createEnvironment()

	for _, filepath in ipairs(testFiles) do
		getTestsForFile(filepath, environment)
	end

	printTable(tests)
end
