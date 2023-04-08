local Error = require("src.errors.error")

lest = lest or {}

---@type table<string, function>
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

--- Mocks a module with an auto-mocked version when it is being required.
--- To manually mock the module, pass a function to `factory` which returns the new module.
---
--- This works slightly differently to jest.mock as it is not hoisted to the top of the file.
---
--- Additionally, when automocking it must first require the module in order to map over its exports.
--- If importing the given module triggers any side effects, you may need to manually mock it with the factory function.
---@param moduleName string
---@param factory? function
---@param options? { virtual: boolean }
function lest.mock(moduleName, factory, options)
	options = options or {}

	local realModule = not options.virtual and lest.requireActual(moduleName)

	if factory then
		moduleMocks[moduleName] = function()
			return factory()
		end
	else
		if options.virtual then
			error(Error("A factory must be used to mock a virtual module"))
		end

		-- We cache the mocked module as require also caches
		local mockedModule = mockValue(realModule, moduleName)
		moduleMocks[moduleName] = function()
			return mockedModule
		end
	end
end

--- Removes the mock for the given module, or throws if the module has not been mocked.
---
--- There is no equivalent to this in Jest. Not to be confused with `lest.unmock`.
---@param moduleName string
function lest.removeModuleMock(moduleName)
	if not moduleMocks[moduleName] then
		error(
			Error(string.format("Module '%s' has not been mocked", moduleName)),
			2
		)
	end

	moduleMocks[moduleName] = nil
end

--- Removes the mock for all mocked modules.
---
--- There is no equivalent to this in Jest. Not to be confused with `lest.unmock`.
function lest.removeAllModuleMocks()
	moduleMocks = {}
end
