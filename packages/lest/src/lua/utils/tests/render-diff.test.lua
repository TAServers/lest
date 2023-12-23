local renderDiff = require("utils.render-diff")
local COLOURS = require("utils.consoleColours")

test.each({
	{
		"primitive before and after",
		123,
		"456",
		string.format(
			"Expected: %s\nReceived: %s",
			COLOURS.EXPECTED("123"),
			COLOURS.RECEIVED('"456"')
		),
	},
	{
		"primitive before, table after",
		123,
		{ 1, 2, 3 },
		string.format(
			"Expected: %s\nReceived: %s",
			COLOURS.EXPECTED("123"),
			COLOURS.RECEIVED("{1, 2, 3}")
		),
	},
	{
		"table before, primitive after",
		{ 1, 2, 3 },
		123,
		string.format(
			"Expected: %s\nReceived: %s",
			COLOURS.EXPECTED("{1, 2, 3}"),
			COLOURS.RECEIVED("123")
		),
	},
	{
		"same primitive before and after",
		1,
		1,
		string.format(
			"Expected: %s\nReceived: serialises to the same string",
			COLOURS.EXPECTED("1")
		),
	},
	{
		"non-recursive equal tables",
		{ foo = 1 },
		{ foo = 1 },
		string.format(
			[[%s
%s

  Table {
    foo = 1,
  }]],
			COLOURS.EXPECTED("- Expected  - 0"),
			COLOURS.RECEIVED("+ Received  + 0")
		),
	},
	{
		"non-recursive tables with different value",
		{ foo = 1 },
		{ foo = 2 },
		string.format(
			[[%s
%s

  Table {
%s
%s
  }]],
			COLOURS.EXPECTED("- Expected  - 1"),
			COLOURS.RECEIVED("+ Received  + 1"),
			COLOURS.EXPECTED("-   foo = 1,"),
			COLOURS.RECEIVED("+   foo = 2,")
		),
	},
	{
		"non-recursive tables with different field",
		{ foo = 1 },
		{ bar = 1 },
		string.format(
			[[%s
%s

  Table {
%s
%s
  }]],
			COLOURS.EXPECTED("- Expected  - 1"),
			COLOURS.RECEIVED("+ Received  + 1"),
			COLOURS.RECEIVED("+   bar = 1,"),
			COLOURS.EXPECTED("-   foo = 1,")
		),
	},
	{
		"non-recursive tables with missing field",
		{ foo = 1 },
		{},
		string.format(
			[[%s
%s

  Table {
%s
  }]],
			COLOURS.EXPECTED("- Expected  - 1"),
			COLOURS.RECEIVED("+ Received  + 0"),
			COLOURS.EXPECTED("-   foo = 1,")
		),
	},
	{
		"recursive tables",
		{ { foo = 1 }, { bar = 2 }, [true] = { baz = 3 } },
		{ { foo = 1 }, { bar = 3 }, [true] = { biz = 3 } },
		string.format(
			[[%s
%s

  Table {
    Table {
      foo = 1,
    },
    Table {
%s
%s
    },
    [true] = Table {
%s
%s
    },
  }]],
			COLOURS.EXPECTED("- Expected  - 2"),
			COLOURS.RECEIVED("+ Received  + 2"),
			COLOURS.EXPECTED("-     bar = 2,"),
			COLOURS.RECEIVED("+     bar = 3,"),
			COLOURS.EXPECTED("-     baz = 3,"),
			COLOURS.RECEIVED("+     biz = 3,")
		),
	},
})(
	"correctly renders %s when deep is true",
	function(_, expectedValue, receivedValue, expectedDiff)
		local rendered = renderDiff(expectedValue, receivedValue, true, false)

		expect(rendered).toBe(expectedDiff)
	end
)

test("handles circular reference in expected table", function()
	local expectedValue = {}
	expectedValue.bar = expectedValue
	local receivedValue = { bar = "5" }

	local rendered = renderDiff(expectedValue, receivedValue, true, false)

	expect(rendered).toBe(
		string.format(
			"%s\n%s\n\n  Table {\n%s\n%s\n  }",
			COLOURS.EXPECTED("- Expected  - 1"),
			COLOURS.RECEIVED("+ Received  + 1"),
			COLOURS.EXPECTED("-   bar = <circular reference>,"),
			COLOURS.RECEIVED('+   bar = "5",')
		)
	)
end)

test("handles circular reference in received table", function()
	local expectedValue = { bar = "5" }
	local receivedValue = {}
	receivedValue.bar = receivedValue

	local rendered = renderDiff(expectedValue, receivedValue, true, false)

	expect(rendered).toBe(
		string.format(
			"%s\n%s\n\n  Table {\n%s\n%s\n  }",
			COLOURS.EXPECTED("- Expected  - 1"),
			COLOURS.RECEIVED("+ Received  + 1"),
			COLOURS.EXPECTED('-   bar = "5",'),
			COLOURS.RECEIVED("+   bar = <circular reference>,")
		)
	)
end)

test("handles circular reference in both tables", function()
	local expectedValue = {}
	expectedValue.bar = expectedValue
	local receivedValue = {}
	receivedValue.bar = receivedValue

	local rendered = renderDiff(expectedValue, receivedValue, true, false)

	expect(rendered).toBe(
		string.format(
			"%s\n%s\n\n  Table {\n%s\n%s\n  }",
			COLOURS.EXPECTED("- Expected  - 1"),
			COLOURS.RECEIVED("+ Received  + 1"),
			COLOURS.EXPECTED("-   bar = <circular reference>,"),
			COLOURS.RECEIVED("+   bar = <circular reference>,")
		)
	)
end)

test("handles non-circular internal reference", function()
	local expectedValue = { a = {}, b = { foo = "bar" } }
	expectedValue.a.b = expectedValue.b
	local receivedValue = { a = {}, b = { foo = "bar" } }
	receivedValue.a.b = receivedValue.b

	local rendered = renderDiff(expectedValue, receivedValue, true, false)

	expect(rendered).toBe(
		string.format(
			[[%s
%s

  Table {
    a = Table {
      b = Table {
        foo = "bar",
      },
    },
    b = Table {
      foo = "bar",
    },
  }]],
			COLOURS.EXPECTED("- Expected  - 0"),
			COLOURS.RECEIVED("+ Received  + 0")
		)
	)
end)

test(
	"serialises the expected value and returns inverted message when inverted",
	function()
		local expectedValue = { 1, 2, 3 }

		local rendered = renderDiff(expectedValue, expectedValue, true, true)

		expect(rendered).toBe("Expected: not " .. COLOURS.EXPECTED("{1, 2, 3}"))
	end
)

test("diff rendering showcase", function()
	local expected = {
		1,
		"banana",
		a = { 1, 2, 3 },
		b = { foo = true, [false] = "bar" },
	}
	expected.a.a = expected.a
	expected.a.b = expected.b

	local received = {
		1,
		"orange",
		a = { 1, 2, 3, 4 },
		b = { foo = "bar", [999] = "baz" },
	}
	received.a.a = received.a
	received.a.b = received.b

	expect(received).toEqual(expected)
end)
