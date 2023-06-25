local prettyValue = require("src.utils.prettyValue")
local assertType = require("src.asserts.type")

---@type lest.Matcher
local function toMatch(ctx, received, pattern)
	assertType(pattern, "string")

	return {
		pass = type(received) == "string" and received:match(pattern) ~= nil,
		message = string.format(
			"Expected %s to%smatch %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(pattern)
		),
	}
end

return {
	toMatch = toMatch,
}
