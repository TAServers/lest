local prettyValue = require("src.utils.prettyValue")
local assertType = require("src.asserts.type")

---@type lest.Matcher
local function toMatch(ctx, received, pattern)
	assertType(pattern, "string")

	local function createMatcherResult(passed)
		return {
			pass = passed,
			message = string.format(
				"Expected %s to%smatch %s",
				prettyValue(received),
				ctx.inverted and " not " or " ",
				prettyValue(pattern)
			),
		}
	end

	if type(received) ~= "string" then
		return createMatcherResult(false)
	end

	return createMatcherResult(received:match(pattern) ~= nil)
end

return {
	toMatch = toMatch,
}
