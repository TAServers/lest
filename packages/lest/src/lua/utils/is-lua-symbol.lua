local KEYWORDS = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

--- Returns true if the value is a string containing a valid Lua symbol
---@param value any
---@return boolean
local function isLuaSymbol(value)
	return type(value) == "string"
		and not KEYWORDS[value]
		and not not string.match(value, "^[_%a][_%a%d]*$")
end

return isLuaSymbol
