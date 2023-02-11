local matchers = require("src.matchers")

local function bindMatcher(matcher, received, inverted)
	return function(expected)
		local result = matcher(received, expected, { inverted = inverted })
		if not result.pass then
			error(result.message)
		end
	end
end

---Expect a value to pass matcher
---@param received any
---@return table
return function(received)
	local boundMatchers = { never = {} }

	for name, matcher in pairs(matchers) do
		boundMatchers[name] = bindMatcher(matcher, received, false)
		boundMatchers.never[name] = bindMatcher(matcher, received, true)
	end

	return boundMatchers
end
