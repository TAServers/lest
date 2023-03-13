--- Asserts the matcher passed. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertPass(result)
	if not result.pass then
		error(debug.traceback("Expected matcher to pass", 2))
	end
end

--- Asserts the matcher failed. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertFail(result)
	if result.pass then
		error(debug.traceback("Expected matcher to fail", 2))
	end
end

--- Asserts the matcher returned the given message. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertMessage(result, message)
	if result.message ~= message then
		error(
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
end

return {
	passed = assertPass,
	failed = assertFail,
	hasMessage = assertMessage,
}
