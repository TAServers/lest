local tablex = require("src.utils.tablex")

---@class ErrorBody: table
---@field message string

---@class Error
---@operator call(...): ErrorBody

--- Registers a new error class
---@param name string
---@param constructor fun(...: any): ErrorBody
---@param metatable? table<string, any> Optional custom metatable
---@return Error
local function registerError(name, constructor, metatable)
	metatable = tablex.merge({
		__tostring = function(self)
			return string.format("%s: %s", name, self.message)
		end,
	}, metatable or {})

	return setmetatable(metatable, {
		__tostring = function()
			return name
		end,
		__call = function(self, ...)
			return setmetatable(constructor(...), metatable)
		end,
	})
end

return registerError
