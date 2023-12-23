local serialiseValue = require("utils.serialise-value")
local sortTableKeys = require("utils.sort-table-keys")
local isLuaSymbol = require("utils.is-lua-symbol")

--- Renders a field in the diff of a table
---@param key any
---@param value any
---@param isArray boolean
---@return string
local function renderTableField(key, value, isArray)
	if isArray then
		return value
	end

	if isLuaSymbol(key) then
		return string.format("%s = %s", key, value)
	end

	return string.format("[%s] = %s", serialiseValue(key), value)
end

--- Returns a sorted list of the union of keys from the expected and received tables
---@param expectedTable table
---@param receivedTable table
---@return any[]
local function getCombinedSortedKeys(expectedTable, receivedTable)
	local keys = {}
	local countedKeys = {}

	for key in pairs(expectedTable) do
		table.insert(keys, key)
		countedKeys[key] = true
	end
	for key in pairs(receivedTable) do
		if not countedKeys[key] then
			table.insert(keys, key)
		end
	end

	sortTableKeys(keys)
	return keys
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

	local nextArrayKey = 1
	for _, key in ipairs(getCombinedSortedKeys(expectedTable, receivedTable)) do
		local expectedValue = expectedTable[key]
		local receivedValue = receivedTable[key]

		local isArray = key == nextArrayKey
		if isArray then
			nextArrayKey = nextArrayKey + 1
		end

		local renderCurrentField = function(prefix, value)
			rendered = string.format(
				"%s%s %s%s,\n",
				rendered,
				prefix,
				indentation,
				renderTableField(key, value, isArray)
			)

			if prefix == "-" then
				expected = expected + 1
			elseif prefix == "+" then
				received = received + 1
			end
		end

		if expectedValue == receivedValue then
			renderCurrentField(" ", serialiseValue(expectedValue))
		elseif expectedValue == nil then
			renderCurrentField("+", serialiseValue(receivedValue))
		elseif receivedValue == nil then
			renderCurrentField("-", serialiseValue(expectedValue))
		elseif visitedTables[expectedValue] or visitedTables[receivedValue] then
			renderCurrentField(
				"-",
				visitedTables[expectedValue] and "-- Circular reference --"
					or serialiseValue(expectedValue)
			)
			renderCurrentField(
				"+",
				visitedTables[receivedValue] and "-- Circular reference --"
					or serialiseValue(receivedValue)
			)
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

			renderCurrentField(" ", valueDiff.rendered)
			expected = expected + valueDiff.expected
			received = received + valueDiff.received
		else
			renderCurrentField("-", serialiseValue(expectedValue))
			renderCurrentField("+", serialiseValue(receivedValue))
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
---@param inverted? boolean # Whether the assertion this diff is for was inverted (Default false)
---@param withColour? boolean # Defaults to true
---@return string
local function renderDiff(expectedValue, receivedValue, inverted, withColour)
	if withColour == nil then
		withColour = true
	end

	if inverted then
		return string.format("Expected: not %s", serialiseValue(expectedValue))
	end

	if type(expectedValue) ~= "table" or type(receivedValue) ~= "table" then
		local serialisedExpected = serialiseValue(expectedValue)
		local serialisedReceived = serialiseValue(receivedValue)

		return string.format(
			"Expected: %s\nReceived: %s",
			serialisedExpected,
			serialisedReceived == serialisedExpected
					and "serialises to the same string"
				or serialisedReceived
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
