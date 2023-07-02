--- Asserts the matcher passed.
---@param result lest.MatcherResult
local function assertPass(result)
	assert(result.pass, debug.traceback("Expected matcher to pass", 2))
end

--- Asserts the matcher failed.
---@param result lest.MatcherResult
local function assertFail(result)
	assert(not result.pass, debug.traceback("Expected matcher to fail", 2))
end

--- Asserts the matcher returned the given message.
---@param result lest.MatcherResult
local function assertMessage(result, message)
	assert(
		result.message == message,
		debug.traceback(
			string.format(
				"Expected message: %s\nReceived message: %s",
				message,
				result.message
			),
			2
		)
	)
end

return {
	passed = assertPass,
	failed = assertFail,
	hasMessage = assertMessage,
}
