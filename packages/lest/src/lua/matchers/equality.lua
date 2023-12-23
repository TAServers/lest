local serialiseValue = require("utils.serialise-value")
local deepEqual = require("utils.deepEqual")
local renderDiff = require("utils.render-diff")

---@type lest.Matcher
local function toBe(ctx, received, expected)
	return {
		pass = received == expected,
		message = renderDiff(expected, received, false, ctx.inverted),
	}
end

---@type lest.Matcher
local function toBeDefined(ctx, received)
	return {
		pass = received ~= nil,
		message = string.format(
			"Expected %s to be %sdefined",
			serialiseValue(received),
			ctx.inverted and "un" or ""
		),
	}
end

---@type lest.Matcher
local function toBeUndefined(ctx, received)
	return {
		pass = received == nil,
		message = string.format(
			"Expected %s to be %sdefined",
			serialiseValue(received),
			ctx.inverted and "" or "un"
		),
	}
end

local function toEqual(ctx, received, expected)
	return {
		pass = deepEqual(received, expected),
		message = renderDiff(expected, received, true, ctx.inverted),
	}
end

---@type lest.Matcher
local function toBeTruthy(ctx, received)
	return {
		pass = not not received,
		message = string.format(
			"Expected %s to%sbe truthy",
			serialiseValue(received),
			ctx.inverted and " not " or " "
		),
	}
end

---@type lest.Matcher
local function toBeFalsy(ctx, received)
	return {
		pass = not received,
		message = string.format(
			"Expected %s to%sbe falsy",
			serialiseValue(received),
			ctx.inverted and " not " or " "
		),
	}
end

---@type lest.Matcher
local function toBeInstanceOf(ctx, received, metatable)
	assert(type(metatable) == "table", "Metatable must be a table")

	return {
		pass = getmetatable(received) == metatable,
		message = string.format(
			"Expected %s to%sbe an instance of %s",
			serialiseValue(received),
			ctx.inverted and " not " or " ",
			serialiseValue(metatable)
		),
	}
end

return {
	toBe = toBe,

	toBeDefined = toBeDefined,
	toBeUndefined = toBeUndefined,
	toBeNil = toBeUndefined,

	toBeTruthy = toBeTruthy,
	toBeFalsy = toBeFalsy,

	toBeInstanceOf = toBeInstanceOf,

	toEqual = toEqual,
}
