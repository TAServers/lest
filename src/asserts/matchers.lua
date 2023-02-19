--- Asserts the matcher passed. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertPass(result)
	assert(result.pass, "Expected matcher to pass")
end

--- Asserts the matcher failed. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertFail(result)
	assert(not result.pass, "Expected matcher to fail")
end

--- Asserts the matcher returned the given message. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertMessage(result, message)
	assert(
		result.message == message,
		string.format(
			"Expected message: %s\nReceived message: %s",
			message,
			result.message
		)
	)
end

return {
	passed = assertPass,
	failed = assertFail,
	hasMessage = assertMessage,
}
