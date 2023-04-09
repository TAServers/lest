local Error = require("src.errors.error")
local assertType = require("src.asserts.type")

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

lest = lest or {}

---@type table<string, table<string, function>>
local moduleMocks = {}

---@type table<string, any>
local requireCache = {}

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
registerImporterMock("loadfile")
registerImporterMock("dofile")

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

		moduleMocks.loadfile[moduleName] = function()
			return factory
		end

		moduleMocks.dofile[moduleName] = factory
	else
		moduleMocks.require[moduleName] = function()
			local module = lest.requireActual(moduleName)
			requireCache[moduleName] = requireCache[moduleName]
				or mockValue(module, moduleName)
			return requireCache[moduleName]
		end

		moduleMocks.loadfile[moduleName] = function()
			local chunk, errorMessage = lest.loadfileActual(moduleName)
			if not chunk then
				return nil, errorMessage
			end

			return function()
				return unpack(mockValue({ chunk() }, moduleName))
			end
		end

		moduleMocks.dofile[moduleName] = function()
			local results = { lest.dofileActual(moduleName) }
			return unpack(mockValue(results, moduleName))
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

	for importerName, _ in pairs(moduleMocks) do
		moduleMocks[importerName][moduleName] = nil
	end

	requireCache[moduleName] = nil
end

--- Removes the mock for all mocked modules.
---
--- There is no equivalent to this in Jest. Not to be confused with `lest.unmock`.
function lest.removeAllModuleMocks()
	for importerName, _ in pairs(moduleMocks) do
		moduleMocks[importerName] = {}
	end

	requireCache = {}
end
