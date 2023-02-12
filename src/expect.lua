local matchers = require("src.matchers")

--- Builds a message for the result with the given context
---@param context lest.MessageContext
---@param result lest.TestResult
---@return string
local function buildMessage(context, result)
	if type(result.message) == "function" then
		return tostring(result.message(context))
	end

	return tostring(result.message)
end

--- Builds a signature for the expect call
---@param name string -- Name of the matcher that was used
---@param args any -- Arguments passed to the matcher
---@param received any
---@param inverted boolean -- True if the condition was inverted
---@return string
local function buildSignature(name, args, received, inverted)
	local stringArgs = {}
	for i, arg in ipairs(args) do
		stringArgs[i] = tostring(arg)
	end

	return string.format(
		"expect(%s)%s.%s(%s)",
		tostring(received),
		inverted and ".never" or "",
		name,
		table.concat(stringArgs, ", ")
	)
end

--- Binds a matcher
---@param name string -- Name of the matcher
---@param matcher lest.Matcher
---@param received any
---@param inverted boolean
---@return function
local function bindMatcher(name, matcher, received, inverted)
	return function(...)
		---@type lest.MessageContext
		local context = {
			inverted = inverted,
		}

		local result = matcher(received, ...)
		if inverted then
			result.pass = not result.pass
		end

		if not result.pass then
			error({
				message = buildMessage(context, result),
				signature = buildSignature(name, { ... }, received, inverted),
			})
		end
	end
end

---Expect a value to pass matcher
---@param received any
---@return table
return function(received)
	---@type table<string, function | table<string, function>>
	local boundMatchers = { never = {} }

	for name, matcher in pairs(matchers) do
		boundMatchers[name] = bindMatcher(name, matcher, received, false)
		boundMatchers.never[name] = bindMatcher(name, matcher, received, true)
	end

	return boundMatchers
end
