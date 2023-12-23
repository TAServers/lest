local serialiseValue = require("utils.serialise-value")

test.each({
	{ "string", "foo", [["foo"]] },
	{ "number", 123, [[123]] },
	{ "boolean", true, [[true]] },
	{ "positive infinity", math.huge, [[inf]] },
	{ "negative infinity", -math.huge, [[-inf]] },
	{ "NaN", 0 / 0, [[NaN]] },
	{
		"table with tostring metamethod",
		setmetatable({}, {
			__tostring = function()
				return "Blah"
			end,
		}),
		[[Blah]],
	},
	{ "array-like table", { 1, "foo", 3 }, [[{1, "foo", 3}]] },
	{
		"object-like table",
		{ foo = true, ["b-ar"] = false },
		[[{["b-ar"] = false, foo = true}]],
	},
	{
		"mixed table",
		{ 1, foo = 2, [true] = 3 },
		[[{1, foo = 2, [true] = 3}]],
	},
	{
		"nested table",
		{ foo = { 1, 2, 3 } },
		[[{foo = {1, 2, 3}}]],
	},
})("serialises %s", function(_, value, expected)
	local serialised = serialiseValue(value)

	expect(serialised).toBe(expected)
end)

test("serialises table with circular reference", function()
	local tbl = { foo = "123" }
	tbl.bar = tbl

	local serialised = serialiseValue(tbl)

	expect(serialised).toBe('{bar = <circular reference>, foo = "123"}')
end)
