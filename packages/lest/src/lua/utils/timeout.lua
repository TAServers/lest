local hook = require("src.lua.utils.hook")
local TimeoutError = require("src.lua.errors.timeout")
local unpack = require("src.lua.utils.unpack")

lest = lest or {}

local function withTimeout(timeout, func, ...)
	local startTime = os.clock()
	local timedOut = false
	local args = { ... }

	local oldSetTimeout = lest.setTimeout
	function lest.setTimeout(newTimeout)
		timeout = newTimeout / 1000
		if oldSetTimeout then
			oldSetTimeout(newTimeout)
		end
	end

	local results = {
		xpcall(function()
			hook.setCountHook(function()
				if not timedOut and os.clock() - startTime > timeout then
					timedOut = true
					error(TimeoutError(timeout))
				end
			end)

			return func(unpack(args))
		end, debug.traceback),
	}

	hook.setCountHook()
	lest.setTimeout = oldSetTimeout

	return unpack(results)
end

return withTimeout
