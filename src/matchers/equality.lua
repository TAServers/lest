---@type lest.Matcher
local function toBe(ctx, received, expected)
	return {
		pass = received == expected,
		message = string.format(
			"Expected %s to%sbe %s",
			tostring(received),
			ctx.inverted and " not " or " ",
			tostring(expected)
		),
	}
end

---@type lest.Matcher
local function toBeDefined(ctx, received) end

---@type lest.Matcher
local function toBeUndefined(ctx, received) end

return {
	toBe = toBe,
	toBeDefined = toBeDefined,
	toBeUndefined = toBeUndefined,
	toBeNil = toBeUndefined,
}
