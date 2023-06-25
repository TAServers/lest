local prettyValue = require("src.utils.prettyValue")
local deepEqual = require("src.utils.deepEqual")
local assertType = require("src.asserts.type")

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
	assertType(expected, "number")

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
local function toHaveBeenNthCalledWith(ctx, received, nthCall, ...)
	received = assertMockFn(received)
	assertType(nthCall, "number")
	assert(nthCall > 0, "Call index must be greater than zero")

	local args = { ... }

	return {
		pass = nthCall <= #received.mock.calls
			and deepEqual(args, received.mock.calls[nthCall]),
		message = string.format(
			"Expected %s to%shave Nth been called with: %s\nCall index: %i",
			tostring(received),
			ctx.inverted and " not " or " ",
			prettyArgs(args),
			nthCall
		),
	}
end

---@type lest.Matcher
local function toHaveReturned(ctx, received, ...)
	received = assertMockFn(received)

	return {
		pass = received.mock.lastResult and true or false,
		message = string.format(
			"Expected %s to%shave returned",
			tostring(received),
			ctx.inverted and " not " or " "
		),
	}
end

---@type lest.Matcher
local function toHaveReturnedTimes(ctx, received, expected)
	received = assertMockFn(received)
	assertType(expected, "number")

	return {
		pass = #received.mock.results == expected,
		message = string.format(
			"Expected %s to%shave returned %i time%s",
			tostring(received),
			ctx.inverted and " not " or " ",
			expected,
			expected == 1 and "" or "s"
		),
	}
end

---@type lest.Matcher
local function toHaveReturnedWith(ctx, received, ...)
	received = assertMockFn(received)

	local retvals = { ... }

	local hasReturnedWithValues = false
	for _, result in ipairs(received.mock.results) do
		if result.type == "return" and deepEqual(retvals, result.value) then
			hasReturnedWithValues = true
			break
		end
	end

	return {
		pass = hasReturnedWithValues,
		message = string.format(
			"Expected %s to%shave returned with: %s",
			tostring(received),
			ctx.inverted and " not " or " ",
			prettyArgs(retvals)
		),
	}
end

---@type lest.Matcher
local function toHaveLastReturnedWith(ctx, received, ...)
	received = assertMockFn(received)

	local retvals = { ... }

	return {
		pass = received.mock.lastResult
			and received.mock.lastResult.type == "return"
			and deepEqual(retvals, received.mock.lastResult.value),
		message = string.format(
			"Expected %s to%shave last returned with: %s",
			tostring(received),
			ctx.inverted and " not " or " ",
			prettyArgs(retvals)
		),
	}
end

---@type lest.Matcher
local function toHaveNthReturnedWith(ctx, received, nthCall, ...)
	received = assertMockFn(received)
	assertType(nthCall, "number")
	assert(nthCall > 0, "Call index must be greater than zero")

	local retvals = { ... }

	return {
		pass = nthCall <= #received.mock.results
			and received.mock.results[nthCall].type == "return"
			and deepEqual(retvals, received.mock.results[nthCall].value),
		message = string.format(
			"Expected %s to%shave Nth returned with: %s\nCall index: %i",
			tostring(received),
			ctx.inverted and " not " or " ",
			prettyArgs(retvals),
			nthCall
		),
	}
end

return {
	toHaveBeenCalled = toHaveBeenCalled,
	toBeCalled = toHaveBeenCalled,

	toHaveBeenCalledTimes = toHaveBeenCalledTimes,
	toBeCalledTimes = toHaveBeenCalledTimes,

	toHaveBeenCalledWith = toHaveBeenCalledWith,
	toBeCalledWith = toHaveBeenCalledWith,

	toHaveBeenLastCalledWith = toHaveBeenLastCalledWith,
	lastCalledWith = toHaveBeenLastCalledWith,

	toHaveBeenNthCalledWith = toHaveBeenNthCalledWith,
	nthCalledWith = toHaveBeenNthCalledWith,

	toHaveReturned = toHaveReturned,
	toReturn = toHaveReturned,

	toHaveReturnedTimes = toHaveReturnedTimes,
	toReturnTimes = toHaveReturnedTimes,

	toHaveReturnedWith = toHaveReturnedWith,
	toReturnWith = toHaveReturnedWith,

	toHaveLastReturnedWith = toHaveLastReturnedWith,
	lastReturnedWith = toHaveLastReturnedWith,

	toHaveNthReturnedWith = toHaveNthReturnedWith,
	nthReturnedWith = toHaveNthReturnedWith,
}
