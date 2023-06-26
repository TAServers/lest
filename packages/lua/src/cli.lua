local OPTIONS = {
	config = {
		takesArg = true,
		default = "lest.config.lua",
	},
	testTimeout = {
		takesArg = true,
		cast = function(val)
			local num = tonumber(val)
			assert(num, "Expected testTimeout to be a number")
			return num
		end,
	},
	json = {
		takesArg = false,
	},
}

local PREFIXED_OPTIONS = {}
for optionName, _ in pairs(OPTIONS) do
	PREFIXED_OPTIONS["--" .. optionName] = optionName
end

local function parseArgs(args)
	local parsed = {}

	local argIdx = 1
	while argIdx <= #args do
		local arg = args[argIdx]
		local optionName = PREFIXED_OPTIONS[arg]

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
		if option.takesArg then
			if not parsed[optionName] then
				parsed[optionName] = option.default
			elseif option.cast then
				parsed[optionName] = option.cast(parsed[optionName])
			end
		end
	end

	return parsed
end

--- Parse command line args
---@param args string[]
---@return table<string, any>
return function(args)
	return parseArgs(args)
end
