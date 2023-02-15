local matchers = require("src.matchers")
local prettyValue = require("src.utils.prettyValue")
local TestResultError = require("src.errors.testresult")

--- Builds a signature for the expect call
---@param name string -- Name of the matcher that was used
---@param args any -- Arguments passed to the matcher
---@param received any
---@param inverted boolean -- True if the condition was inverted
---@return string
local function buildSignature(name, args, received, inverted)
	local stringArgs = {}
	for i, arg in ipairs(args) do
		stringArgs[i] = prettyValue(arg)
	end

	return string.format(
		"expect(%s)%s.%s(%s)",
		prettyValue(received),
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
		---@type lest.MatcherContext
		local context = {
			inverted = inverted,
		}

		local result = matcher(context, received, ...)
		if inverted then
			result.pass = not result.pass
		end

		if not result.pass then
			error(
				TestResultError(
					tostring(result.message),
					buildSignature(name, { ... }, received, inverted)
				)
			)
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
