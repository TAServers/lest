--- Sorts an array of keys in-place first by value for numeric keys, and then lexicographically
---
--- Useful for rendering tables with mixed syntax (e.g. `{1, 2, [111] = 3, a = 4}`)
---@param keys any[]
local function sortTableKeys(keys)
	table.sort(keys, function(a, b)
		local aIsNumber = type(a) == "number"
		local bIsNumber = type(b) == "number"

		if aIsNumber then
			return not bIsNumber or a < b
		end

		return not bIsNumber and tostring(a) < tostring(b)
	end)
end

return sortTableKeys
