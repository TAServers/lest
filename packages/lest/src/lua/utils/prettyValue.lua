local MAX_TABLE_FIELDS = 3

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

--- Renders a primitive value, or table with tostring
---@param value any
---@return string
local function renderPrimitive(value)
	if type(value) == "string" then
		return '"' .. value .. '"'
	end

	if value == math.huge then
		return "inf"
	end

	if value == -math.huge then
		return "-inf"
	end

	if value ~= value then
		return "NaN"
	end

	return tostring(value)
end

--- Renders an inline truncated table
---@param tbl table
---@return string
local function renderTable(tbl)
	local renderedFields = {}
	local totalFields = 0

	for key, value in sortedPairs(tbl) do
		if #renderedFields < MAX_TABLE_FIELDS then
			if type(key) == "number" then
				table.insert(renderedFields, renderPrimitive(value))
			elseif
				type(key) == "string" and string.match(key, "^[_%a][_%a%d]*$")
			then
				table.insert(
					renderedFields,
					string.format("%s = %s", key, renderPrimitive(value))
				)
			else
				table.insert(
					renderedFields,
					string.format(
						"[%s] = %s",
						renderPrimitive(key),
						renderPrimitive(value)
					)
				)
			end
		end

		totalFields = totalFields + 1
	end

	if #renderedFields < totalFields then
		table.insert(
			renderedFields,
			string.format("...%d more", totalFields - #renderedFields)
		)
	end

	return string.format("{ %s }", table.concat(renderedFields, ", "))
end

--- Formats a value to look prettier
---@param value any
---@return string
return function(value)
	if
		type(value) == "table"
		and string.match(tostring(value), "table: [%a%d]+")
	then
		return renderTable(value)
	end

	return renderPrimitive(value)
end
