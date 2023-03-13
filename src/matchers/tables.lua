local prettyValue = require("src.utils.prettyValue")
local deepEqual = require("src.utils.deepEqual")
local assertType = require("src.asserts.type")

---@type lest.Matcher
local function toHaveLength(ctx, received, length)
	assertType(length, "number")

	local success, comparison = pcall(function()
		return #received == length
	end)

	return {
		pass = success and comparison,
		message = string.format(
			"Expected %s to%shave a length of %d",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			length
		),
	}
end

---@type lest.Matcher
local function toContain(ctx, received, item)
	local pass = false

	if type(received) == "string" then
		pass = received:find(tostring(item), 1, true) ~= nil
	elseif type(received) == "table" then
		for _, value in pairs(received) do
			if value == item then
				pass = true
				break
			end
		end
	end

	return {
		pass = pass,
		message = string.format(
			"Expected %s to%scontain %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(item)
		),
	}
end

---@type lest.Matcher
local function toContainEqual(ctx, received, item)
	local pass = false

	if type(received) == "table" then
		for _, value in pairs(received) do
			if deepEqual(value, item) then
				pass = true
				break
			end
		end
	end

	return {
		pass = pass,
		message = string.format(
			"Expected %s to%scontain %s with deep equality",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(item)
		),
	}
end

---@type lest.Matcher
local function toMatchObject(ctx, received, object)
	assertType(object, "table")

	--- Internal recursive function to determine if any property of `a` matches with `b`.
	---@param a table
	---@param b table
	local function matches(a, b)
		if #a ~= #b then
			-- This is done because this usually means that .toMatchObject
			-- was called with an array of objects. Jest's .toMatchObject enforces
			-- that each array is the same length. However, if a and b are just dictionaries, this
			-- condition will pass because the length operator does not count string keys.
			return false
		end

		for aKey, aValue in pairs(a) do
			local bValue = b[aKey]

			if type(aValue) == "table" and type(bValue) == "table" then
				if not matches(aValue, bValue) then
					return false
				end
			elseif bValue ~= nil and aValue ~= bValue then
				return false
			end
		end

		return true
	end

	return {
		pass = type(received) == "table" and matches(received, object),
		message = string.format(
			"Expected %s to%smatch %s",
			prettyValue(received),
			ctx.inverted and " not " or " ",
			prettyValue(object)
		),
	}
end

return {
	toHaveLength = toHaveLength,
	toContain = toContain,
	toContainEqual = toContainEqual,
	toMatchObject = toMatchObject,
	toMatchTable = toMatchObject,
}
