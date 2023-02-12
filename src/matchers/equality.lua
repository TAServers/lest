local prettyValue = require("src.utils.prettyValue")
local deepEqual = require("src.utils.deepEqual")

---@type lest.Matcher
local function toBe(ctx, received, expected)
	return {
		pass = received == expected,
		message = string.format(
			"Expected %s to%sbe %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeDefined(ctx, received)
	return {
		pass = received ~= nil,
		message = string.format(
			"Expected %s to be %sdefined",
			prettyValue(received),
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
			prettyValue(received),
			ctx.inverted and "" or "un"
		),
	}
end

local function toEqual(ctx, received, expected)
	return {
		pass = deepEqual(received, expected),
		message = string.format(
			"Expected %s to%sdeeply equal %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeTruthy(ctx, received) end

---@type lest.Matcher
local function toBeFalsy(ctx, received) end

---@type lest.Matcher
local function toBeInstanceOf(ctx, received, metatable) end

return {
	toBe = toBe,

	toBeDefined = toBeDefined,
	toBeUndefined = toBeUndefined,
	toBeNil = toBeUndefined,

	toEqual = toEqual,
}
