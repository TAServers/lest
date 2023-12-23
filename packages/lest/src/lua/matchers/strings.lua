local serialiseValue = require("utils.serialise-value")
local assertType = require("asserts.type")

---@type lest.Matcher
local function toMatch(ctx, received, pattern)
	assertType(pattern, "string")

	return {
		pass = type(received) == "string" and received:match(pattern) ~= nil,
		message = string.format(
			"Expected %s to%smatch %s",
			serialiseValue(received),
			ctx.inverted and " not " or " ",
			serialiseValue(pattern)
		),
	}
end

return {
	toMatch = toMatch,
}
