--- Calculates if the real length of a table is zero. This is used to check for empty dictionaries and arrays.
---@param tbl table
---@return boolean
local function isEmpty(tbl)
	local length = 0
	for _, _ in pairs(tbl) do
		length = length + 1
	end

	return length == 0
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

--- Returns true if a table is numerically inconsistent. This means that the table has holes or nonsequential indices.
--- Because arrays are emulated in Lua using tables, this function can be used to determine if a table is an array or not.
---@param tbl any
---@return boolean
local function isNumericallyInconsistent(tbl)
	local lastKey = 0
	for key, _ in ipairs(tbl) do
		if type(key) ~= "number" then
			return false
		end

		if key ~= lastKey + 1 then
			return true
		end

		lastKey = key
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

	if isNumericallyInconsistent(tbl) then
		error("Nonsequential numerically indexed tables are not supported.")
	end

	if isMixed(tbl) then
		error("Mixed tables are not supported.")
	end

	visitedTables = visitedTables or {}
	visitedTables[tbl] = true

	local function printValue(value)
		if type(value) == "string" then
			return ('"%s"'):format(value)
		elseif type(value) == "number" then
			return tostring(value)
		elseif type(value) == "boolean" then
			return value and "true" or "false"
		elseif type(value) == "table" then
			if visitedTables[value] then
				error(
					"Cyclic table member found! Cyclic tables are not supported."
				)
			end

			return printJSON(value, visitedTables)
		else
			error(("Unsupported type: %s"):format(type(value)))
		end
	end

	local startCharacter = isDictionary(tbl) and "{" or "["
	local endCharacter = isDictionary(tbl) and "}" or "]"

	if isEmpty(tbl) then
		return startCharacter .. endCharacter
	end

	local json = startCharacter
	for key, value in pairs(tbl) do
		local keyString = isDictionary(tbl) and ('"%s":'):format(key) or ""
		local valueString = printValue(value)
		json = ("%s%s%s,"):format(json, keyString, valueString)
	end

	json = json:sub(1, -2) -- Remove trailing comma

	return json .. endCharacter
end

return printJSON
