local matchers = require("src.matchers")

local function bindMatcher(name, matcher, received, inverted)
	return function(expected)
		local result = matcher(received, expected, { inverted = inverted })
		if not result.pass then
			error({
				message = result.message,
				signature = string.format(
					"expect(%s)%s.%s(%s)",
					tostring(received),
					inverted and ".never" or "",
					name,
					tostring(expected)
				),
			})
		end
	end
end

---Expect a value to pass matcher
---@param received any
---@return table
return function(received)
	local boundMatchers = { never = {} }

	for name, matcher in pairs(matchers) do
		boundMatchers[name] = bindMatcher(name, matcher, received, false)
		boundMatchers.never[name] = bindMatcher(name, matcher, received, true)
	end

	return boundMatchers
end
