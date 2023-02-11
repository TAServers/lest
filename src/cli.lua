local OPTIONS = {
	config = {
		alias = "c",
		takesArg = true,
		default = "lest.config.lua",
	},
}

local PREFIXED_OPTIONS = {}
local ALIASES = {}
for optionName, option in pairs(OPTIONS) do
	PREFIXED_OPTIONS["--" .. optionName] = optionName
	if option.alias then
		ALIASES["-" .. option.alias] = optionName
	end
end

local function parseArgs(args)
	local parsed = {}

	local argIdx = 1
	while argIdx <= #args do
		local arg = args[argIdx]
		local optionName = PREFIXED_OPTIONS[arg] or ALIASES[arg]

		if not optionName then
			error("Unknown option: " .. arg)
		end

		local option = OPTIONS[optionName]
		if option.takesArg then
			argIdx = argIdx + 1
			if not args[argIdx] then
				error(
					"Option " .. arg .. " takes one value, but none were given"
				)
			end

			parsed[optionName] = args[argIdx]
		else
			parsed[optionName] = true
		end

		argIdx = argIdx + 1
	end

	for optionName, option in pairs(OPTIONS) do
		if option.takesArg and option.default and not parsed[optionName] then
			parsed[optionName] = option.default
		end
	end

	return parsed
end

--- Parse command line args
---@param args string[]
---@return table<string, string>
return function(args)
	return parseArgs(args)
end
