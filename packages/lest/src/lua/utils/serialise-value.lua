local sortTableKeys = require("utils.sort-table-keys")
local isLuaSymbol = require("utils.is-lua-symbol")

local PRINTABLE_REPLACEMENTS = {
	["\\"] = [[\\]],
	['"'] = [[\"]],
	["'"] = [[\']],
}

local NON_PRINTABLE_REPLACEMENTS = {
	["\a"] = [[\a]],
	["\b"] = [[\b]],
	["\f"] = [[\f]],
	["\n"] = [[\n]],
	["\r"] = [[\r]],
	["\t"] = [[\t]],
	["\v"] = [[\v]],
}

local function serialiseString(str)
	return '"'
		.. str:gsub("[\\\"']", PRINTABLE_REPLACEMENTS)
			:gsub("[^\032-\126]", function(match)
				return NON_PRINTABLE_REPLACEMENTS[match]
					or string.format([[\%d]], string.byte(match, 1))
			end)
		.. '"'
end

--- Iterator function which returns elements in numeric then lexicographic order
---@param tbl table
---@return fun(): any, any
local function sortedPairs(tbl)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	sortTableKeys(keys)

	local i = 1
	return function()
		local key = keys[i]
		if key ~= nil then
			i = i + 1
			return key, tbl[key]
		end
	end
end

local serialiseValue

--- Serialises an inline truncated table
---@param tbl table
---@param visitedTables table<table, boolean>
---@return string
local function serialiseTable(tbl, visitedTables)
	local renderedFields = {}
	local nextArrayIndex = 1

	for key, value in sortedPairs(tbl) do
		if type(key) == "number" and key == nextArrayIndex then
			table.insert(renderedFields, serialiseValue(value, visitedTables))
			nextArrayIndex = nextArrayIndex + 1
		elseif isLuaSymbol(key) then
			table.insert(
				renderedFields,
				string.format(
					"%s = %s",
					key,
					serialiseValue(value, visitedTables)
				)
			)
		else
			table.insert(
				renderedFields,
				string.format(
					"[%s] = %s",
					serialiseValue(key, visitedTables),
					serialiseValue(value, visitedTables)
				)
			)
		end
	end

	return string.format("{%s}", table.concat(renderedFields, ", "))
end

--- Serialises a value recursively
---@param value any
---@param visitedTables? table<table, boolean>
---@return string
serialiseValue = function(value, visitedTables)
	visitedTables = visitedTables or {}

	if type(value) == "string" then
		return serialiseString(value)
	end

	-- TODO: Replace with math.huge and update tests
	if value == math.huge then
		return "inf"
	end

	if value == -math.huge then
		return "-inf"
	end

	if value ~= value then
		return "NaN"
	end

	if
		type(value) == "table"
		and string.match(tostring(value), "table: [%a%d]+")
	then
		if visitedTables[value] then
			return "<circular reference>"
		end

		local visitedTablesCopy = {}
		for k, v in pairs(visitedTables) do
			visitedTablesCopy[k] = v
		end
		visitedTablesCopy[value] = true

		return serialiseTable(value, visitedTablesCopy)
	end

	if type(value) == "function" then
		return "<function>"
	end

	if type(value) == "userdata" then
		return "<userdata>"
	end

	return tostring(value)
end

return serialiseValue
