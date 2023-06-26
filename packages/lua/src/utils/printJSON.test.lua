local printJSON = require("src.utils.printJSON")

describe("printJSON", function()
	describe("should refuse", function()
		test("cyclic tables", function()
			-- Arrange
			local tbl = {}
			tbl[1] = "foo!"
			tbl[2] = tbl

			-- Act
			local success, err = pcall(printJSON, tbl)

			-- Assert
			expect(success).toBe(false)
			expect(err).toContain(
				"Cyclic table member found! Cyclic tables are not supported."
			)
		end)

		test("mixed tables", function()
			-- Arrange
			local tbl = {
				foo = "bar",
				"baz",
			}

			-- Act
			local success, err = pcall(printJSON, tbl)

			-- Assert
			expect(success).toBe(false)
			expect(err).toContain("Mixed tables are not supported.")
		end)
	end)

	-- A explanation for the way this test is written:
	-- Lua iterators, except for ipairs, have NO DETERMINISTIC ORDER.
	-- This means it is effectively IMPOSSIBLE to test the order of the keys in the JSON string.
	-- So, we have to simply check if it contains the elements required. This is why we use toContain.
	test.each({
		{
			{
				foo = "bar",
				baz = "qux",
			},
			{
				'"foo":"bar"',
				'"baz":"qux"',
			},
		},
		{
			{
				1,
				2,
				3,
				4,
			},
			{
				"1",
				"2",
				"3",
				"4",
			},
		},
		{
			{
				foo = {
					bar = {
						baz = "qux",
					},
				},
			},
			{
				'"foo":{"bar":{"baz":"qux"}}',
			},
		},
		{
			{
				iq = 20,
				height = 45,
				weeklySleepTimes = { 1, 3, 4, 2, 3 },
			},
			{
				'"iq":20',
				'"height":45',
				'"weeklySleepTimes":[1,3,4,2,3]',
			},
		},
		{
			{
				[1] = 1,
				[2] = 2,
				[4] = 3,
				[3] = 4,
			},
			{
				"[1,2,4,3]",
			},
		},
		{
			{
				test = '"hello my darling"',
			},
			{
				'"test":"\\"hello my darling\\""',
			},
		},
	})(
		"should print valid JSON given a lua table",
		function(testTable, expectedElements)
			-- Act
			local result = printJSON(testTable)

			-- Assert
			for _, element in ipairs(expectedElements) do
				expect(result).toContain(element)
			end
		end
	)
end)
