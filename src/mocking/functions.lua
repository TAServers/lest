local tablex = require("src.utils.tablex")
local assertType = require("src.asserts.type")

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

lest = lest or {}

lest._realType = lest._realType or type

function _G.type(v)
	if lest.isMockFunction(v) then
		return "function"
	end

	return lest._realType(v)
end

---@class lest.Mock : function
---@field mock { calls: any[][], lastCall?: any[], results: lest.MockResult[], lastResult?: lest.MockResult }
---@field protected _name string
---@field protected _implementation function
---@field protected _implementationStack function[]
local mockMeta = {}
mockMeta.__index = mockMeta

function mockMeta:__call(...)
	local function pushResult(result)
		self.mock.lastResult = result
		tablex.push(self.mock.results, self.mock.lastResult)
	end

	local args = { ... }
	local implementation = table.remove(self._implementationStack, 1)
		or self._implementation

	local result = { pcall(implementation, ...) }
	local success = table.remove(result, 1)

	self.mock.lastCall = args
	tablex.push(self.mock.calls, self.mock.lastCall)

	if success then
		pushResult({
			type = "return",
			value = result,
		})

		return unpack(result)
	end

	pushResult({
		type = "throw",
		value = result[1],
	})

	error(result[1])
end

function mockMeta:__tostring()
	return self._name
end

--- Sets the name that will be used for the mock in test outputs
---@param name string
---@return self
function mockMeta:mockName(name)
	assertType(name, "string")

	self._name = name
	return self
end

--- Gets the name that will be used for the mock in test outputs
---@return string
function mockMeta:getMockName()
	return self._name
end

--- Mocks the function's implementation
---@param implementation function
---@return self
function mockMeta:mockImplementation(implementation)
	assertType(implementation, "function")

	self._implementation = implementation
	return self
end

--- Gets the implementation for the mock
---@return function
function mockMeta:getMockImplementation()
	return self._implementation
end

--- Mocks the function's implementation for one call
---@param implementation function
---@return self
function mockMeta:mockImplementationOnce(implementation)
	assertType(implementation, "function")

	tablex.push(self._implementationStack, implementation)
	return self
end

--- Mocks the function's return value(s)
---@param ... any
---@return self
function mockMeta:mockReturnValue(...)
	local args = { ... }

	return self:mockImplementation(function()
		return unpack(args)
	end)
end

--- Mocks the function's return value(s) for one call
---@param ... any
---@return self
function mockMeta:mockReturnValueOnce(...)
	local args = { ... }

	return self:mockImplementationOnce(function()
		return unpack(args)
	end)
end

--- Shorthand for `
--- lest.fn():mockImplementation(function(self) return self end)
--- `
---
--- Useful for functions that chain
---@return lest.Mock
function mockMeta:mockReturnThis()
	return self:mockImplementation(function(this)
		return this
	end)
end

--- Clears all information stored in the `mockFn.mock` table
---
--- Note that this replaces `mockFn.mock`, not its contents.
--- Make sure you're not storing a stale reference to the old table
---
--- To also reset mocked implementations and return values, use `mockFn:mockReset()`
function mockMeta:mockClear()
	self.mock = { calls = {}, results = {} }
end

--- Does everything that `mockFn:mockClear()` does, and also removes any mocked return values or implementations
function mockMeta:mockReset()
	self:mockClear()

	self._implementation = function() end
	self._implementationStack = {}
end

---@type lest.Mock[]
local allMocks = {}

--- Creates a new mock function
---@param implementation? function
---@return lest.Mock
function lest.fn(implementation)
	implementation = implementation or function() end
	assertType(implementation, "function")

	local mockFn = setmetatable({
		_implementation = implementation,
		_implementationStack = {},
		_name = "lest.fn()",
		mock = { calls = {}, results = {} },
	}, mockMeta)

	tablex.push(allMocks, mockFn)

	return mockFn
end

--- Returns true if the passed value is a mock function
---@param value any
---@return boolean
function lest.isMockFunction(value)
	return getmetatable(value) == mockMeta
end

function lest.clearAllMocks()
	for _, mockFn in ipairs(allMocks) do
		mockFn:mockClear()
	end
end

function lest.resetAllMocks()
	for _, mockFn in ipairs(allMocks) do
		mockFn:mockReset()
	end
end
