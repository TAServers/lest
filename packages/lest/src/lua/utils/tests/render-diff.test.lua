local renderDiff = require("utils.render-diff")

test.each({
	{
		"primitive before and after",
		123,
		"456",
		[[Expected: 123
Received: "456"]],
	},
	{
		"primitive before, table after",
		123,
		{ 1, 2, 3 },
		[[Expected: 123
Received: {1, 2, 3}]],
	},
	{
		"table before, primitive after",
		{ 1, 2, 3 },
		123,
		[[Expected: {1, 2, 3}
Received: 123]],
	},
	{
		"same primitive before and after",
		1,
		1,
		[[Expected: 1
Received: serialises to the same string]],
	},
	{
		"non-recursive equal tables",
		{ foo = 1 },
		{ foo = 1 },
		[[- Expected  - 0
+ Received  + 0

  Table {
    foo = 1,
  }]],
	},
	{
		"non-recursive tables with different value",
		{ foo = 1 },
		{ foo = 2 },
		[[- Expected  - 1
+ Received  + 1

  Table {
-   foo = 1,
+   foo = 2,
  }]],
	},
	{
		"non-recursive tables with different field",
		{ foo = 1 },
		{ bar = 1 },
		[[- Expected  - 1
+ Received  + 1

  Table {
+   bar = 1,
-   foo = 1,
  }]],
	},
	{
		"non-recursive tables with missing field",
		{ foo = 1 },
		{},
		[[- Expected  - 1
+ Received  + 0

  Table {
-   foo = 1,
  }]],
	},
	{
		"recursive tables",
		{ { foo = 1 }, { bar = 2 }, [true] = { baz = 3 } },
		{ { foo = 1 }, { bar = 3 }, [true] = { biz = 3 } },
		[[- Expected  - 2
+ Received  + 2

  Table {
    Table {
      foo = 1,
    },
    Table {
-     bar = 2,
+     bar = 3,
    },
    [true] = Table {
-     baz = 3,
+     biz = 3,
    },
  }]],
	},
})(
	"correctly renders %s",
	function(_, expectedValue, receivedValue, expectedDiff)
		local rendered = renderDiff(expectedValue, receivedValue, false)

		expect(rendered).toBe(expectedDiff)
	end
)

test("handles circular reference in expected table", function()
	local expectedValue = {}
	expectedValue.bar = expectedValue
	local receivedValue = { bar = "5" }

	local rendered = renderDiff(expectedValue, receivedValue, false)

	expect(rendered).toBe([[- Expected  - 1
+ Received  + 1

  Table {
-   bar = -- Circular reference --,
+   bar = "5",
  }]])
end)

test("handles circular reference in received table", function()
	local expectedValue = { bar = "5" }
	local receivedValue = {}
	receivedValue.bar = receivedValue

	local rendered = renderDiff(expectedValue, receivedValue, false)

	expect(rendered).toBe([[- Expected  - 1
+ Received  + 1

  Table {
-   bar = "5",
+   bar = -- Circular reference --,
  }]])
end)

test("handles circular reference in both tables", function()
	local expectedValue = {}
	expectedValue.bar = expectedValue
	local receivedValue = {}
	receivedValue.bar = receivedValue

	local rendered = renderDiff(expectedValue, receivedValue, false, false)

	expect(rendered).toBe([[- Expected  - 1
+ Received  + 1

  Table {
-   bar = -- Circular reference --,
+   bar = -- Circular reference --,
  }]])
end)

test(
	"serialises the expected value and returns inverted message when inverted",
	function()
		local expectedValue = { 1, 2, 3 }

		local rendered = renderDiff(expectedValue, expectedValue, true, false)

		expect(rendered).toBe("Expected: not {1, 2, 3}")
	end
)
