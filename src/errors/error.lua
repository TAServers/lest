local Error = setmetatable({}, {
	__tostring = function()
		return "Error"
	end,
})

function Error:__tostring()
	return "Error"
end

function Error:extend(name)
	return setmetatable({
		super = self,
		throw = self.throw,
		__tostring = function()
			return name
		end,
	}, {
		__tostring = function()
			return name
		end,
	})
end

function Error:throw(message, level)
	error(
		setmetatable({
			message = message,
		}, self),
		(level or 1) + 1
	)
end

return Error
