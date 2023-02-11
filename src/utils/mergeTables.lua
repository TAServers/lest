--- Merge tables into one
---@param ... table
---@return table
return function(...)
	local merged

	for _, tbl in ipairs({ ... }) do
		if merged then
			for k, v in pairs(tbl) do
				merged[k] = v
			end
		else
			merged = tbl
		end
	end

	return merged or {}
end
