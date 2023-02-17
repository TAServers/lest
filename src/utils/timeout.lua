local hook = require("src.utils.hook")
local TimeoutError = require("src.errors.timeout")

lest = lest or {}

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local function withTimeout(timeout, func, ...)
	local startTime = os.clock()
	local timedOut = false

	local oldSetTimeout = lest.setTimeout
	function lest.setTimeout(newTimeout)
		timeout = newTimeout / 1000
		if oldSetTimeout then
			oldSetTimeout(newTimeout)
		end
	end

	local results = {
		pcall(function(...)
			hook.setCountHook(function()
				if not timedOut and os.clock() - startTime > timeout then
					timedOut = true
					error(TimeoutError(timeout))
				end
			end)

			return func(...)
		end, ...),
	}

	hook.setCountHook()
	lest.setTimeout = oldSetTimeout

	return unpack(results)
end

return withTimeout
