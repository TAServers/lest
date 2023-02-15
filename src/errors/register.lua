---@class Error
---@operator call(...): table

--- Registers a new error class
---@param name string
---@param constructor fun(...: any): table
---@return Error
local function registerError(name, constructor)
	local function __tostring()
		return name
	end

	local meta = { __tostring = __tostring }

	return setmetatable(meta, {
		__tostring = __tostring,
		__call = function(self, ...)
			return setmetatable(constructor(...), meta)
		end,
	})
end

return registerError
