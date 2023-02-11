--- Builds an environment by adding or replacing functions in the global scope
---
--- Returns a function to revert back to the original globals
---@param env table
---@return function
return function(env)
	local old = {}
	for k, v in pairs(env) do
		old[k] = _G[k]
		_G[k] = v
	end

	return function()
		for k, v in pairs(env) do
			_G[k] = old[k]
		end
	end
end
