---@class ErrorBody: table
---@field message string

---@class Error
---@operator call(...): ErrorBody

--- Registers a new error class
---@param name string
---@param constructor fun(...: any): ErrorBody
---@return Error
local function registerError(name, constructor)
	local meta = {
		__tostring = function(self)
			return string.format("%s: %s", name, self.message)
		end,
	}

	return setmetatable(meta, {
		__tostring = function()
			return name
		end,
		__call = function(self, ...)
			return setmetatable(constructor(...), meta)
		end,
	})
end

return registerError
