local hook = require("src.utils.hook")
local TimeoutError = require("src.errors.timeout")

---@diagnostic disable-next-line: deprecated
local unpack = table.unpack or unpack

local function withTimeout(timeout, func, ...)
	local startTime = os.clock()
	local timedOut = false

	hook.setLineHook(function()
		if not timedOut and os.clock() - startTime > timeout then
			timedOut = true
			TimeoutError:throw()
		end
	end)

	local results = { pcall(func, ...) }

	hook.setLineHook()

	return unpack(results)
end

return withTimeout
