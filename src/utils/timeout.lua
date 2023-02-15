local hook = require("src.utils.hook")
local TimeoutError = require("src.errors.timeout")

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local function withTimeout(timeout, func, ...)
	local startTime = os.clock()
	local timedOut = false

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

	return unpack(results)
end

return withTimeout
