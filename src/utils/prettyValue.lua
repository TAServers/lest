--- Formats a value to look prettier
---@param value any
---@return string
return function(value)
	if type(value) == "string" then
		return '"' .. value .. '"'
	end

	return tostring(value)
end
