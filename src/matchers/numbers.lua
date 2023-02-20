local prettyValue = require("src.utils.prettyValue")

---@type lest.Matcher
local function toBeCloseTo(ctx, received, expected, numDigits)
	local expectedDiff = math.pow(10, -numDigits) / 2
	local receivedDiff = math.abs(expected - received)

	local pass = receivedDiff < expectedDiff

	return {
		pass = pass,
		message = string.format(
			"Expected %s to%sbe close to %s within %s digits",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected),
			prettyValue(numDigits)
		),
	}
end

---@type lest.Matcher
local function toBeGreaterThan(ctx, received, expected)
	return {
		pass = received > expected,
		message = string.format(
			"Expected %s to%sbe greater than %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeGreaterThanOrEqual(ctx, received, expected) end

---@type lest.Matcher
local function toBeLessThan(ctx, received, expected) end

---@type lest.Matcher
local function toBeLessThanOrEqual(ctx, received, expected) end

---@type lest.Matcher
local function toBeNaN(ctx, received) end

---@type lest.Matcher
local function toBeInfinity(ctx, received) end

return {
	toBeCloseTo = toBeCloseTo,
	toBeGreaterThan = toBeGreaterThan,
}
