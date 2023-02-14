local Error = require("src.errors.error")

local TimeoutError = Error:extend("TimeoutError")

function TimeoutError:throw(level)
	self.super.throw(self, "Function call timed out", (level or 1) + 1)
end

return TimeoutError
