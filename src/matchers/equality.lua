local prettyValue = require("src.utils.prettyValue")

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

return {
	toBe = toBe,
	toBeDefined = toBeDefined,
	toBeUndefined = toBeUndefined,
	toBeNil = toBeUndefined,
}
