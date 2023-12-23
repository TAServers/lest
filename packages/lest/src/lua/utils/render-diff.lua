local serialiseValue = require("utils.serialise-value")

--- Renders a field in the diff of a table
---@param prefix " "|"-"|"+"
---@param indentation string
---@param key any
---@param value any
---@param shouldPrettyPrintValue? boolean # Defaults to true
---@return string
local function renderTableField(
	prefix,
	indentation,
	key,
	value,
	shouldPrettyPrintValue
)
	if shouldPrettyPrintValue == nil then
		shouldPrettyPrintValue = true
	end

	return string.format(
		"%s %s[%s] = %s,\n",
		prefix,
		indentation,
		serialiseValue(key),
		shouldPrettyPrintValue and serialiseValue(value) or value
	)
end

--- Renders a difference between two tables with optional indentation and highlighting
---@param expectedTable table
---@param receivedTable table
---@param withColour boolean
---@param indentation? string
---@param visitedTables? table<table, boolean>
---@return table
local function renderTableDiff(
	expectedTable,
	receivedTable,
	withColour,
	indentation,
	visitedTables
)
	indentation = indentation or "  "
	visitedTables = visitedTables or {}
	local rendered = "Table {\n"
	local expected = 0
	local received = 0

	visitedTables[expectedTable] = true
	visitedTables[receivedTable] = true

	for key, expectedValue in pairs(expectedTable) do
		local receivedValue = receivedTable[key]

		if expectedValue == receivedValue then
			rendered = rendered
				.. renderTableField(" ", indentation, key, expectedValue)
		elseif receivedValue == nil then
			rendered = rendered
				.. renderTableField("-", indentation, key, expectedValue)
			expected = expected + 1
		elseif visitedTables[expectedValue] or visitedTables[receivedValue] then
			rendered = rendered
				.. renderTableField(
					"-",
					indentation,
					key,
					visitedTables[expectedValue] and "-- Circular reference --"
						or expectedValue,
					not visitedTables[expectedValue]
				)
				.. renderTableField(
					"+",
					indentation,
					key,
					visitedTables[receivedValue] and "-- Circular reference --"
						or receivedValue,
					not visitedTables[receivedValue]
				)
			expected = expected + 1
			received = received + 1
		elseif
			type(expectedValue) == "table"
			and type(receivedValue) == "table"
		then
			local valueDiff = renderTableDiff(
				expectedValue,
				receivedValue,
				withColour,
				indentation .. "  ",
				visitedTables
			)

			rendered = rendered
				.. renderTableField(
					" ",
					indentation,
					key,
					valueDiff.rendered,
					false
				)
			expected = expected + valueDiff.expected
			received = received + valueDiff.received
		else
			rendered = rendered
				.. renderTableField("-", indentation, key, expectedValue)
				.. renderTableField("+", indentation, key, receivedValue)
			expected = expected + 1
			received = received + 1
		end
	end

	for key, value in pairs(receivedTable) do
		if expectedTable[key] == nil then
			rendered = rendered
				.. renderTableField("+", indentation, key, value)
			received = received + 1
		end
	end

	return {
		rendered = rendered .. indentation .. "}",
		expected = expected,
		received = received,
	}
end

--- Renders the difference between two values with optional ANSI colour highlighting
---@param expectedValue any
---@param receivedValue any
---@param withColour? boolean # Defaults to false
---@return string
local function renderDiff(expectedValue, receivedValue, withColour)
	if type(expectedValue) ~= "table" or type(receivedValue) ~= "table" then
		return string.format(
			"Expected: %s\nReceived: %s",
			serialiseValue(expectedValue),
			serialiseValue(receivedValue)
		)
	end

	local diff =
		renderTableDiff(expectedValue, receivedValue, not not withColour)
	return string.format(
		"- Expected  - %d\n+ Received  + %d\n\n  %s",
		diff.expected,
		diff.received,
		diff.rendered
	)
end

return renderDiff
