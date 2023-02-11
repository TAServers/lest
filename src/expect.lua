local matchers = require("src.matchers")

---Expect a value to pass matcher
---@param expected any
---@return table
return function(expected)
	return setmetatable({
		expected = expected,
		invert = false,
	}, matchers)
end
