local tablex = require("src.utils.tablex")

lest = lest or {}

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

---@alias lest.MockResult { type: "return" | "throw", value: any }

---@class lest.Mock
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
function mockMeta:mockName(name)
	self._name = name
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

--- Creates a new mock function
---@param implementation? function
---@return lest.Mock
function lest.fn(implementation)
	return setmetatable({
		_implementation = implementation or function() end,
		_implementationStack = {},
		_name = "jest.fn()",
		mock = { calls = {}, results = {} },
	}, mockMeta)
end

--- Returns true if the passed value is a mock function
---@param value any
---@return boolean
function lest.isMockFunction(value)
	return getmetatable(value) == mockMeta
end
