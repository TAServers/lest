--- Asserts the matcher passed.
---@param result lest.MatcherResult
local function assertPass(result)
	if not result.pass then
		error("Expected matcher to pass", 2)
	end
end

--- Asserts the matcher failed.
---@param result lest.MatcherResult
local function assertFail(result)
	if result.pass then
		error("Expected matcher to fail", 2)
	end
end

--- Asserts the matcher returned the given message.
---@param result lest.MatcherResult
local function assertMessage(result, message)
	if result.message ~= message then
		error(
			string.format(
				"Expected message: %s\nReceived message: %s",
				message,
				result.message
			),
			2
		)
	end
end

return {
	passed = assertPass,
	failed = assertFail,
	hasMessage = assertMessage,
}
