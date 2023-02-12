--- Performs a deep equality check between two values
---@param a any
---@param b any
---@param visited table<table, table<table, boolean>>
---@return boolean
local function deepEqual(a, b, visited)
	if a == b then
		return true
	end

	if type(a) == "table" and type(b) == "table" then
		visited[a] = visited[a] or {}
		visited[a][b] = true

		for k, v in pairs(a) do
			if
				(not visited[v] or not visited[v][b[k]])
				and not deepEqual(v, b[k], visited)
			then
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

--- Performs a deep equality check between two values
---@param a any
---@param b any
---@return boolean
return function(a, b)
	return deepEqual(a, b, {})
end
