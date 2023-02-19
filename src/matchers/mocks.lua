local prettyValue = require("src.utils.prettyValue")
local deepEqual = require("src.utils.deepEqual")

local function prettyArgs(args)
	local argStrings = {}
	for i, arg in ipairs(args) do
		argStrings[i] = prettyValue(arg)
	end

	return table.concat(argStrings, ", ")
end

--- Throws if the value is not a mock function
---@param value any
---@return lest.Mock
local function assertMockFn(value)
	if not lest.isMockFunction(value) then
		error(string.format("%s is not a mock function", prettyValue(value)), 3)
	end

	return value
end

---@type lest.Matcher
local function toHaveBeenCalled(ctx, received)
	received = assertMockFn(received)

	return {
		pass = received.mock.lastCall and true or false,
		message = string.format(
			"Expected %s to%shave been called",
			tostring(received),
			ctx.inverted and " not " or " "
		),
	}
end

---@type lest.Matcher
local function toHaveBeenCalledTimes(ctx, received, expected)
	received = assertMockFn(received)

	return {
		pass = #received.mock.calls == expected,
		message = string.format(
			"Expected %s to%shave been called %i time%s",
			tostring(received),
			ctx.inverted and " not " or " ",
			expected,
			expected == 1 and "" or "s"
		),
	}
end

---@type lest.Matcher
local function toHaveBeenCalledWith(ctx, received, ...)
	received = assertMockFn(received)

	local args = { ... }

	local hasBeenCalledWithArgs = false
	for _, call in ipairs(received.mock.calls) do
		if deepEqual(args, call) then
			hasBeenCalledWithArgs = true
			break
		end
	end

	return {
		pass = hasBeenCalledWithArgs,
		message = string.format(
			"Expected %s to%shave been called with: %s",
			tostring(received),
			ctx.inverted and " not " or " ",
			prettyArgs(args)
		),
	}
end

---@type lest.Matcher
local function toHaveBeenLastCalledWith(ctx, received, ...)
	received = assertMockFn(received)

	local args = { ... }

	return {
		pass = deepEqual(args, received.mock.lastCall),
		message = string.format(
			"Expected %s to%shave last been called with: %s",
			tostring(received),
			ctx.inverted and " not " or " ",
			prettyArgs(args)
		),
	}
end

---@type lest.Matcher
local function toHaveBeenNthCalledWith(ctx, received, ...) end

---@type lest.Matcher
local function toHaveReturned(ctx, received, ...) end

---@type lest.Matcher
local function toHaveReturnedTimes(ctx, received, ...) end

---@type lest.Matcher
local function toHaveReturnedWith(ctx, received, ...) end

---@type lest.Matcher
local function toHaveLastReturnedWith(ctx, received, ...) end

---@type lest.Matcher
local function toHaveNthReturnedWith(ctx, received, ...) end

return {
	toHaveBeenCalled = toHaveBeenCalled,
	toBeCalled = toHaveBeenCalled,

	toHaveBeenCalledTimes = toHaveBeenCalledTimes,
	toBeCalledTimes = toHaveBeenCalledTimes,

	toHaveBeenCalledWith = toHaveBeenCalledWith,
	toBeCalledWith = toHaveBeenCalledWith,

	toHaveBeenLastCalledWith = toHaveBeenLastCalledWith,
	lastCalledWith = toHaveBeenLastCalledWith,
}
