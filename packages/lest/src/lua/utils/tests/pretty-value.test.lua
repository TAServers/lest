local prettyValue = require("utils.prettyValue")

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
	{ "array-like table", { 1, "foo", 3 }, [[{ 1, "foo", 3 }]] },
	{
		"object-like table",
		{ foo = true, ["b-ar"] = false },
		[[{ ["b-ar"] = false, foo = true }]],
	},
	{
		"mixed table",
		{ 1, foo = 2, [true] = 3 },
		[[{ 1, foo = 2, [true] = 3 }]],
	},
	{
		"truncated array-like table",
		{ 1, 2, 3, 4, 5 },
		[[{ 1, 2, 3, ...2 more }]],
	},
	{
		"truncated object-like table",
		{ a = 1, ["b"] = 2, ["c-"] = 3, d = 4 },
		[[{ a = 1, b = 2, ["c-"] = 3, ...1 more }]],
	},
	{
		"truncated mixed table",
		{ 1, foo = "bar", 2, 3, 4, 5, 6 },
		[[{ 1, 2, 3, ...4 more }]],
	},
})("prettifies %s", function(_, value, expected)
	local rendered = prettyValue(value)

	expect(rendered).toBe(expected)
end)
