local tablex = require("src.utils.tablex")

--- Calculates if the real length of a table is zero. This is used to check for empty dictionaries and arrays.
---@param tbl table
---@return boolean
local function isEmpty(tbl)
	return next(tbl) == nil
end

local function isDictionary(tbl)
	return #tbl == 0
end

local function isMixed(tbl)
	local keyType = nil
	for key, _ in pairs(tbl) do
		if keyType and type(key) ~= keyType then
			return true
		end

		keyType = type(key)
	end

	return false
end

--- Prints a table as JSON.
--- Unsupported types: userdata, function, thread, nonsequential numerically indexed tables (tables with holes or nonsequential indices, since there are no arrays in lua).
--- Cyclic tables are NOT supported.
---@param tbl table
local function printJSON(tbl, visitedTables)
	if type(tbl) ~= "table" then
		error(("Expected table, got %s"):format(type(tbl)))
	end

	if isMixed(tbl) then
		error("Mixed tables are not supported.")
	end

	visitedTables = visitedTables or {}
	visitedTables[tbl] = true

	local function printValue(value)
		local typeOfValue = type(value)
		if typeOfValue == "string" then
			return ('"%s"'):format(value:gsub('"', '\\"'))
		elseif typeOfValue == "number" then
			return tostring(value)
		elseif typeOfValue == "boolean" then
			return value and "true" or "false"
		elseif typeOfValue == "table" then
			if visitedTables[value] then
				error(
					"Cyclic table member found! Cyclic tables are not supported."
				)
			end

			return printJSON(value, visitedTables)
		else
			error(("Unsupported type: %s"):format(typeOfValue))
		end
	end

	local startCharacter, endCharacter = "[", "]"
	local iterator = ipairs
	if isDictionary(tbl) then
		startCharacter, endCharacter = "{", "}"
		iterator = pairs
	end

	if isEmpty(tbl) then
		return startCharacter .. endCharacter
	end

	local members = {}
	for key, value in iterator(tbl) do
		local keyString = isDictionary(tbl) and ('"%s":'):format(key) or ""
		local valueString = printValue(value)
		tablex.push(members, table.concat({ keyString, valueString }))
	end

	local json = startCharacter .. table.concat(members, ",") .. endCharacter
	return json
end

return printJSON
