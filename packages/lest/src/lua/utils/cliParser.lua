local OPTION_PATTERNS = {
	"%-%-([%a%-]+)=([^%s]+)",
	"%-%-([%a%-]+)",
	"%-([%a%-]+)=([^%s]+)",
	"%-([%a%-]+)",
}

local function matchOption(arg)
	for _, pattern in ipairs(OPTION_PATTERNS) do
		local key, value = string.match(arg, pattern)
		if key then
			return key, value or "true"
		end
	end
end

--- Parses command line options given as an arg array
---@param args string[]
---@return table<string, string>
local function parseCliOptions(args)
	local parsed = {}

	for _, arg in ipairs(args) do
		local key, value = matchOption(arg)
		if key and value then
			parsed[key] = value
		end
	end

	return parsed
end

return parseCliOptions
