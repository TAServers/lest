local prettyValue = require("src.lua.utils.prettyValue")

local function printTable(table, currDepth, maxDepth)
	local indent = string.rep(" ", currDepth * 4)

	if currDepth > maxDepth then
		print(indent .. "<max depth>")
		return
	end

	for k, v in pairs(table) do
		if type(v) == "table" then
			print(string.format("%s[%s] = {", indent, prettyValue(k)))
			printTable(v, currDepth + 1, maxDepth)
			print(indent .. "},")
		else
			print(
				string.format(
					"%s[%s] = %s,",
					indent,
					prettyValue(k),
					prettyValue(v)
				)
			)
		end
	end
end

--- Prints a table to the console
---@param table table
---@param depth? integer
return function(table, depth)
	depth = depth or 2

	print("{")
	printTable(table, 1, depth)
	print("}")
end
