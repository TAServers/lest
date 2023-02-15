local hook = require("src.utils.hook")
local TimeoutError = require("src.errors.timeout")

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local function withTimeout(timeout, func, ...)
	local startTime = os.clock()
	local timedOut = false
	print("OUTSIDE HOOK", timeout)

	hook.setCountHook(function()
		print("INSIDE HOOK", timeout)
		if not timedOut and os.clock() - startTime > timeout then
			timedOut = true
			error(TimeoutError(timeout))
		end
	end)

	local results = { pcall(func, ...) }

	hook.setCountHook()

	return unpack(results)
end

return withTimeout
