return {
	--- Pushes a value to the end of the table
	---@param tbl table
	---@param value any
	push = function(tbl, value)
		tbl[#tbl + 1] = value
	end,

	--- Pops and returns the value from the end of the table
	---@param tbl table
	---@return any
	pop = function(tbl)
		return table.remove(tbl, #tbl)
	end,

	--- Merges multiple tables together
	---
	--- Duplicate fields will be overridden in the order the tables were passed
	---@param ... table
	---@return table
	merge = function(...)
		local merged = {}

		for _, tbl in ipairs({ ... }) do
			for k, v in pairs(tbl) do
				merged[k] = v
			end
		end

		return merged or {}
	end,

	--- Appends the values of each array into a single array
	---
	--- Order of the elements is maintained
	---@param ... any[]
	---@return any[]
	squash = function(...)
		local squashed, offset = {}, 0

		for _, tbl in ipairs({ ... }) do
			local lastIndex = 0
			for i, v in ipairs(tbl) do
				squashed[i + offset] = v
				lastIndex = i
			end

			offset = offset + lastIndex
		end

		return squashed
	end,
}
