--- Performs a deep equality check between two values
---@param a any
---@param b any
---@return boolean
local function deepEqual(a, b)
	if a == b then
		return true
	end

	if type(a) == "table" and type(b) == "table" then
		for k, v in pairs(a) do
			if not deepEqual(b[k], v) then
				return false
			end
		end

		for k, _ in pairs(b) do
			if a[k] == nil then
				return false
			end
		end

		return true
	end

	return false
end

return deepEqual
