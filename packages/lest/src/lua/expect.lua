local COLOURS = require("utils.consoleColours")

local matchers = require("matchers")
local TestResultError = require("errors.testresult")

--- Builds a signature for the expect call
---@param name string -- Name of the matcher that was used
---@param inverted boolean -- True if the condition was inverted
---@return string
local function buildSignature(name, inverted)
	return string.format(
		"%s%s%s%s.%s%s%s%s",
		COLOURS.DIMMED("expect("),
		COLOURS.RECEIVED("received"),
		COLOURS.DIMMED(")"),
		inverted and ".never" or "",
		COLOURS.HIGHLIGHT(name),
		COLOURS.DIMMED("("),
		COLOURS.EXPECTED("expected"),
		COLOURS.DIMMED(")")
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
					buildSignature(name, inverted)
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
