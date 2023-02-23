local prettyValue = require("src.utils.prettyValue")
local INFINITY = math.huge

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
local function toBeGreaterThanOrEqual(ctx, received, expected)
	return {
		pass = received >= expected,
		message = string.format(
			"Expected %s to%sbe greater than or equal to %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeLessThan(ctx, received, expected)
	return {
		pass = received < expected,
		message = string.format(
			"Expected %s to%sbe less than %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeLessThanOrEqual(ctx, received, expected)
	return {
		pass = received <= expected,
		message = string.format(
			"Expected %s to%sbe less than or equal to %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeNaN(ctx, received)
	return {
		pass = received ~= received,
		message = string.format(
			"Expected %s to%sbe NaN",
			prettyValue(received),
			ctx.inverted and " not " or " "
		),
	}
end

---@type lest.Matcher
local function toBeInfinity(ctx, received)
	return {
		pass = received == INFINITY,
		message = string.format(
			"Expected %s to%sbe infinity",
			prettyValue(received),
			ctx.inverted and " not " or " "
		),
	}
end

return {
	toBeCloseTo = toBeCloseTo,

	toBeGreaterThan = toBeGreaterThan,
	toBeGreaterThanOrEqual = toBeGreaterThanOrEqual,
	toBeLessThan = toBeLessThan,
	toBeLessThanOrEqual = toBeLessThanOrEqual,

	toBeNaN = toBeNaN,
	toBeInfinity = toBeInfinity,
}
