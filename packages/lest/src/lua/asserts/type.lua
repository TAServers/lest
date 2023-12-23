local TypeError = require("errors.type")
local serialiseValue = require("utils.serialise-value")

--- Asserts the object is of the specified type
---
--- If `typeStringOrMeta` is a string it uses `type()`, otherwise it uses `getmetatable`
---@param object any
---@param typeStringOrMeta type | table
---@param label? string
---@param level? number
return function(object, typeStringOrMeta, label, level)
	label = label or serialiseValue(object)
	level = (level or 1) + 1

	if
		type(object) == typeStringOrMeta
		or getmetatable(object) == typeStringOrMeta
	then
		return
	end

	if type(typeStringOrMeta) == "string" then
		error(
			TypeError(
				string.format("Expected %s to be a %s", label, typeStringOrMeta)
			),
			level
		)
	end

	if type(typeStringOrMeta) == "table" then
		error(
			TypeError(
				string.format(
					"Expected %s to be an instance of %s",
					label,
					serialiseValue(typeStringOrMeta)
				)
			),
			level
		)
	end

	error(TypeError("typeStringOrMeta must be either a string or a table"), 2)
end
