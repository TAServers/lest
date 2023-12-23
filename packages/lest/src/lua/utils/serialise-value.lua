--- Iterator function which returns elements in numeric then lexicographic order
---@param tbl table
---@return fun(): any, any
local function sortedPairs(tbl)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		local aIsNumber = type(a) == "number"
		local bIsNumber = type(b) == "number"

		if aIsNumber then
			return not bIsNumber or a < b
		end

		return not bIsNumber and tostring(a) < tostring(b)
	end)

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
---@return string
local function serialiseTable(tbl)
	local renderedFields = {}
	local nextArrayIndex = 1

	for key, value in sortedPairs(tbl) do
		if type(key) == "number" and key == nextArrayIndex then
			table.insert(renderedFields, serialiseValue(value))
			nextArrayIndex = nextArrayIndex + 1
		elseif
			type(key) == "string" and string.match(key, "^[_%a][_%a%d]*$")
		then
			table.insert(
				renderedFields,
				string.format("%s = %s", key, serialiseValue(value))
			)
		else
			table.insert(
				renderedFields,
				string.format(
					"[%s] = %s",
					serialiseValue(key),
					serialiseValue(value)
				)
			)
		end
	end

	return string.format("{%s}", table.concat(renderedFields, ", "))
end

--- Serialises a value recursively
---@param value any
---@return string
serialiseValue = function(value)
	if type(value) == "string" then
		return '"' .. value .. '"'
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
		return serialiseTable(value)
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
