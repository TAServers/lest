local assertType = require("src.lua.asserts.type")

---@type lest.Matcher
local function toThrow(ctx, received, expected)
	local success, err = pcall(received)

	if not expected then
		return {
			pass = not success,
			message = string.format(
				"Expected function to%sthrow",
				ctx.inverted and " not " or " "
			),
		}
	end

	assertType(expected, "string")

	return {
		pass = not success and string.match(tostring(err), expected),
		message = string.format(
			"Expected function to%sthrow %s\nReceived: %s",
			ctx.inverted and " not " or " ",
			expected,
			tostring(err)
		),
	}
end

return {
	toThrow = toThrow,
	toThrowError = toThrow,
}
