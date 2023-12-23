local serialiseValue = require("utils.serialise-value")
local sortTableKeys = require("utils.sort-table-keys")
local isLuaSymbol = require("utils.is-lua-symbol")
local COLOURS = require("utils.consoleColours")

local CIRCULAR_REFERENCE_TEXT = "<circular reference>"

local COLOURS_BY_PREFIX = {
	[" "] = function(text)
		return text
	end,
	["-"] = COLOURS.EXPECTED,
	["+"] = COLOURS.RECEIVED,
}

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

--- Renders a difference between two tables
---@param expectedTable table
---@param receivedTable table
---@param indentation? string
---@param visitedTables? table<table, boolean>
---@return table
local function renderTableDiff(
	expectedTable,
	receivedTable,
	indentation,
	visitedTables
)
	indentation = indentation or "  "
	local rendered = "Table {\n"
	local expected = 0
	local received = 0

	local visitedTablesCopy = {}
	for k, v in pairs(visitedTables or {}) do
		visitedTablesCopy[k] = v
	end
	visitedTablesCopy[expectedTable] = true
	visitedTablesCopy[receivedTable] = true

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
				"%s%s\n",
				rendered,
				COLOURS_BY_PREFIX[prefix](
					string.format(
						"%s %s%s,",
						prefix,
						indentation,
						renderTableField(key, value, isArray)
					)
				)
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
		elseif
			visitedTablesCopy[expectedValue] or visitedTablesCopy[receivedValue]
		then
			renderCurrentField(
				"-",
				visitedTablesCopy[expectedValue] and CIRCULAR_REFERENCE_TEXT
					or serialiseValue(expectedValue)
			)
			renderCurrentField(
				"+",
				visitedTablesCopy[receivedValue] and CIRCULAR_REFERENCE_TEXT
					or serialiseValue(receivedValue)
			)
		elseif
			type(expectedValue) == "table"
			and type(receivedValue) == "table"
		then
			local valueDiff = renderTableDiff(
				expectedValue,
				receivedValue,
				indentation .. "  ",
				visitedTablesCopy
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

--- Renders the difference between two values with ANSI colour highlighting
---@param expectedValue any
---@param receivedValue any
---@param deep boolean # Whether to render a deep equality diff
---@param inverted? boolean # Whether the assertion this diff is for was inverted (Default false)
---@return string
local function renderDiff(expectedValue, receivedValue, deep, inverted)
	if inverted then
		return string.format(
			"Expected: not %s",
			COLOURS.EXPECTED(serialiseValue(expectedValue))
		)
	end

	if
		not deep
		or type(expectedValue) ~= "table"
		or type(receivedValue) ~= "table"
	then
		local serialisedExpected = serialiseValue(expectedValue)
		local serialisedReceived = serialiseValue(receivedValue)

		return string.format(
			"Expected: %s\nReceived: %s",
			COLOURS.EXPECTED(serialisedExpected),
			serialisedReceived == serialisedExpected
					and "serialises to the same string"
				or COLOURS.RECEIVED(serialisedReceived)
		)
	end

	local diff = renderTableDiff(expectedValue, receivedValue)
	return string.format(
		"%s\n%s\n\n  %s",
		COLOURS.EXPECTED(string.format("- Expected  - %d", diff.expected)),
		COLOURS.RECEIVED(string.format("+ Received  + %d", diff.received)),
		diff.rendered
	)
end

return renderDiff
