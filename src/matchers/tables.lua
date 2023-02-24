local prettyValue = require("src.utils.prettyValue")
local deepEqual = require("src.utils.deepEqual")

---@type lest.Matcher
local function toHaveLength(ctx, received, length)
	local receivedLen = #received

	return {
		pass = receivedLen == length,
		message = string.format(
			"Expected %s to%shave the length of %d",
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
		pass = received:find(item) ~= nil
	elseif type(received) == "table" then
		for _, value in pairs(received) do
			if value == item then
				pass = true
				break
			end
		end
	else
		error("Expected to receive a string or a table")
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
	else
		error("Expected to receive a table")
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
local function toMatchObject(ctx, received, object) end

return {
	toHaveLength = toHaveLength,
	toContain = toContain,
	toContainEqual = toContainEqual,
}
