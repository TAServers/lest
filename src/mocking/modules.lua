local Error = require("src.errors.error")
local assertType = require("src.asserts.type")

lest = lest or {}

---@type table<string, table<string, function>>
local moduleMocks = {}

local function registerImporterMock(importerName)
	moduleMocks[importerName] = {}

	local actualFunctionName = importerName .. "Actual"
	lest[actualFunctionName] = lest[actualFunctionName] or _G[importerName]

	_G[importerName] = function(moduleName)
		local moduleFactory = moduleMocks[importerName][moduleName]
		if moduleFactory then
			return moduleFactory()
		end

		return lest[actualFunctionName](moduleName)
	end
end

registerImporterMock("require")

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

--- Mocks a module with an auto-mocked version when it is being required.
--- To manually mock the module, pass a function to `factory` which returns the new module.
---
--- This works slightly differently to jest.mock as it is not hoisted to the top of the file.
---
--- Additionally, when automocking it must first require the module in order to map over its exports.
--- If importing the given module triggers any side effects, you may need to manually mock it with the factory function.
---@param moduleName string
---@param factory? function
function lest.mock(moduleName, factory)
	assertType(moduleName, "string", "moduleName", 2)
	if factory then
		assertType(factory, "function", "factory", 2)
	end

	if factory then
		moduleMocks.require[moduleName] = function()
			local firstRetval = factory()
			return firstRetval
		end
	else
		-- We cache the mocked module as require also caches
		local mockedModule =
			mockValue(lest.requireActual(moduleName), moduleName)
		moduleMocks.require[moduleName] = function()
			return mockedModule
		end
	end
end

--- Removes the mock for the given module, or throws if the module has not been mocked.
---
--- There is no equivalent to this in Jest. Not to be confused with `lest.unmock`.
---@param moduleName string
function lest.removeModuleMock(moduleName)
	assertType(moduleName, "string", "moduleName", 2)

	if not moduleMocks.require[moduleName] then
		error(
			Error(string.format("Module '%s' has not been mocked", moduleName)),
			2
		)
	end

	moduleMocks.require[moduleName] = nil
end

--- Removes the mock for all mocked modules.
---
--- There is no equivalent to this in Jest. Not to be confused with `lest.unmock`.
function lest.removeAllModuleMocks()
	moduleMocks.require = {}
end
