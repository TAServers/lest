lest = lest or {}

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

---@alias lest.MockResult { type: "return" | "throw", value: any }

---@class lest.Mock
---@field mock { calls: any[][], lastCall?: any[], results: lest.MockResult[] }
---@field protected _implementation function
---@field protected _name string
local mockMeta = {}
mockMeta.__index = mockMeta

function mockMeta:__call(...)
	local args = { ... }
	local result = { pcall(self._implementation, ...) }
	local success = table.remove(result, 1)

	self.mock.lastCall = args
	self.mock.calls[#self.mock.calls + 1] = self.mock.lastCall

	if success then
		self.mock.results[#self.mock.results + 1] = {
			type = "return",
			value = result,
		}

		return unpack(result)
	end

	self.mock.results[#self.mock.results + 1] = {
		type = "throw",
		value = result[1],
	}

	error(result[1])
end

function mockMeta:__tostring()
	return self._name
end

function mockMeta:mockName(name)
	self._name = name
end

function mockMeta:mockImplementation(implementation)
	self._implementation = implementation
end

function mockMeta:mockReturnValue(...)
	local args = { ... }
	self:mockImplementation(function()
		return unpack(args)
	end)
end

--- Creates a new mock function
---@param implementation? function
---@return lest.Mock
function lest.fn(implementation)
	return setmetatable({
		_implementation = implementation or function() end,
		_name = "jest.fn()",
		mock = { calls = {}, results = {} },
	}, mockMeta)
end
