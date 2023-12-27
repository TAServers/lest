local serialiseValue = require("utils.serialise-value")
local assertType = require("asserts.type")

---@type lest.Matcher
local function toBeCloseTo(ctx, received, expected, numDigits)
	-- Matches Jest's default digits.
	numDigits = numDigits == nil and 2 or numDigits

	assertType(expected, "number")
	assertType(numDigits, "number")

	local function createMatcherResult(passed)
		return {
			pass = passed,
			message = string.format(
				"Expected %s to%sbe close to %s (%d decimal places)",
				serialiseValue(received),
				ctx.inverted and " not " or " ",
				serialiseValue(expected),
				numDigits
			),
		}
	end

	if type(received) ~= "number" then
		return createMatcherResult(false)
	end

	if expected == received then
		return createMatcherResult(true)
	end

	local expectedDiff = math.pow(10, -numDigits) / 2
	local receivedDiff = math.abs(expected - received)
	return createMatcherResult(receivedDiff < expectedDiff)
end

---@type lest.Matcher
local function toBeGreaterThan(ctx, received, expected)
	assertType(expected, "number")

	local success, comparison = pcall(function()
		return received > expected
	end)

	return {
		pass = success and comparison,
		message = string.format(
			"Expected %s to%sbe greater than %s",
			serialiseValue(received),
			ctx.inverted and " not " or " ",
			serialiseValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeGreaterThanOrEqual(ctx, received, expected)
	assertType(expected, "number")

	local success, comparison = pcall(function()
		return received >= expected
	end)

	return {
		pass = success and comparison,
		message = string.format(
			"Expected %s to%sbe greater than or equal to %s",
			serialiseValue(received),
			ctx.inverted and " not " or " ",
			serialiseValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeLessThan(ctx, received, expected)
	assertType(expected, "number")

	local success, comparison = pcall(function()
		return received < expected
	end)

	return {
		pass = success and comparison,
		message = string.format(
			"Expected %s to%sbe less than %s",
			serialiseValue(received),
			ctx.inverted and " not " or " ",
			serialiseValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeLessThanOrEqual(ctx, received, expected)
	assertType(expected, "number")

	local success, comparison = pcall(function()
		return received <= expected
	end)

	return {
		pass = success and comparison,
		message = string.format(
			"Expected %s to%sbe less than or equal to %s",
			serialiseValue(received),
			ctx.inverted and " not " or " ",
			serialiseValue(expected)
		),
	}
end

---@type lest.Matcher
local function toBeNaN(ctx, received)
	return {
		pass = type(received) == "number" and received ~= received,
		message = string.format(
			"Expected %s to%sbe NaN",
			serialiseValue(received),
			ctx.inverted and " not " or " "
		),
	}
end

---@type lest.Matcher
local function toBeInfinity(ctx, received)
	return {
		pass = type(received) == "number" and math.abs(received) == math.huge,
		message = string.format(
			"Expected %s to%sbe infinity",
			serialiseValue(received),
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
