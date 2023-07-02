--- Formats a value to look prettier
---@param value any
---@return string
return function(value)
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
