lest = lest or {}

---@type table<string, fun(): any>
local moduleMocks = {}

lest.requireActual = lest.requireActual or require

function require(moduleName)
	if moduleMocks[moduleName] then
		return moduleMocks[moduleName]()
	end

	return lest.requireActual(moduleName)
end

local mockTable
local function mockValue(val, path)
	if type(val) == "table" then
		return mockTable(val, path)
	end

	if type(val) == "function" then
		return lest.fn():mockName(path)
	end

	return val
end

mockTable = function(tbl, path)
	local mocked = {}

	for k, v in pairs(tbl) do
		mocked[k] = mockValue(v, path .. "->" .. tostring(k))
	end

	return mocked
end

--- Builds a module factory from a module
---@param moduleName any
local function autoMock(moduleName)
	local module = require(moduleName)

	return function()
		return mockValue(module, moduleName)
	end
end

--- Mocks a module with an auto-mocked version when it is being required.
--- To manually mock the module, pass a function to `factory` which returns the new module.
---
--- This works slightly differently to jest.mock as it is not hoisted to the top of the file.
---
--- Additionally, when automocking it must first require the module in order to map over its exports.
--- If importing the given module triggers any side effects, you may need to manually mock it with the factory function.
---@param moduleName string
---@param factory? fun(): any
function lest.mock(moduleName, factory)
	moduleMocks[moduleName] = factory or autoMock(moduleName)
end
