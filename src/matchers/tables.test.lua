local matchers = require("src.matchers.tables")
local assertMatcher = require("src.asserts.matchers")
local prettyValue = require("src.utils.prettyValue")

describe("table matchers", function()
	local CONTEXT = {
		inverted = false,
	}

	local INVERTED_CONTEXT = {
		inverted = true,
	}

	describe("toHaveLength", function()
		it(
			"should pass when the received object has the expected length",
			function()
				-- Given
				local testArray = { 1, 2, 3 }
				local testTable = { a = 1, b = 2, c = 3 }
				local testString = "abcde"

				-- When
				local resultArray = matchers.toHaveLength(CONTEXT, testArray, 3)
				local resultTable = matchers.toHaveLength(CONTEXT, testTable, 0)
				local resultString =
					matchers.toHaveLength(CONTEXT, testString, 5)

				-- Then
				assertMatcher.passed(resultArray)
				assertMatcher.passed(resultTable)
				assertMatcher.passed(resultString)
			end
		)

		it(
			"should fail when the received object doesn't has the expected length",
			function()
				-- Given
				local testArray = { 2, 3, 4 }

				-- When
				local resultArray = matchers.toHaveLength(CONTEXT, testArray, 4)

				-- Then
				assertMatcher.failed(resultArray)
				assertMatcher.hasMessage(
					resultArray,
					("Expected %s to have the length of %d"):format(
						prettyValue(testArray),
						4
					)
				)
			end
		)

		it("should have an inverted message", function()
			-- Given
			local testArray = { 2, 3, 4 }

			-- When
			local resultArray =
				matchers.toHaveLength(INVERTED_CONTEXT, testArray, 4)

			-- Then
			assertMatcher.hasMessage(
				resultArray,
				("Expected %s to not have the length of %d"):format(
					prettyValue(testArray),
					4
				)
			)
		end)
	end)

	describe("toContain", function()
		describe("should pass", function()
			test(
				"when the received object contains the expected item",
				function()
					-- Given
					local testArray = { 1, 2, "foo" }
					local testItem = "foo"

					-- When
					local result =
						matchers.toContain(CONTEXT, testArray, testItem)

					-- Then
					assertMatcher.passed(result)
				end
			)

			test(
				"when the received object is a string and it contains the expected substring",
				function()
					-- Given
					local testString = "foobar"
					local testItem = "foo"

					-- When
					local result =
						matchers.toContain(CONTEXT, testString, testItem)

					-- Then
					assertMatcher.passed(result)
				end
			)
		end)

		describe("should fail", function()
			test(
				"when the received object doesn't contain the expected item",
				function()
					-- Given
					local testArray = { 1, 2, "foo" }
					local testItem = "quux"

					-- When
					local result =
						matchers.toContain(CONTEXT, testArray, testItem)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %s to contain %s"):format(
							prettyValue(testArray),
							prettyValue(testItem)
						)
					)
				end
			)

			test(
				"when the received object is a string and it doesn't contains the expected substring",
				function()
					-- Given
					local testString = "foobar"
					local testItem = "quux"

					-- When
					local result =
						matchers.toContain(CONTEXT, testString, testItem)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %s to contain %s"):format(
							prettyValue(testString),
							prettyValue(testItem)
						)
					)
				end
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local testArray = { 1, 10 }
			local testItem = 10

			-- When
			local result =
				matchers.toContain(INVERTED_CONTEXT, testArray, testItem)

			-- Given
			assertMatcher.hasMessage(
				result,
				("Expected %s to not contain %s"):format(
					prettyValue(testArray),
					prettyValue(testItem)
				)
			)
		end)
	end)

	describe("toContainEqual", function()
		it(
			"should pass when the received object contains the expected item with deep equality",
			function()
				-- Given
				local testArray = { 1, { hello = 10, hi = { turn = 10 } }, 2 }
				local testItem = { hello = 10, hi = { turn = 10 } }

				-- When
				local result =
					matchers.toContainEqual(CONTEXT, testArray, testItem)

				-- Then
				assertMatcher.passed(result)
			end
		)

		it(
			"should fail when the received object doesn't contains the expected item with deep equality",
			function()
				-- Given
				local testArray = { 1, { hello = 10, hi = { turn = 10 } }, 2 }
				local testItem = { foo = 10, bar = { quux = 10 } }

				-- When
				local result =
					matchers.toContainEqual(CONTEXT, testArray, testItem)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(
					result,
					("Expected %s to contain %s with deep equality"):format(
						prettyValue(testArray),
						prettyValue(testItem)
					)
				)
			end
		)

		it("should have an inverted message", function()
			-- Given
			local testArray = { 1, 30, 10 }
			local testItem = 30

			-- When
			local result =
				matchers.toContainEqual(INVERTED_CONTEXT, testArray, testItem)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %s to not contain %s with deep equality"):format(
					prettyValue(testArray),
					prettyValue(testItem)
				)
			)
		end)
	end)

	describe("toMatchObject", function()
		describe("should pass", function()
			test(
				"when the received object matches the expected object",
				function()
					-- Given
					local testObject = {
						a = 10,
						b = "eleven",
						c = "quux",
					}

					local testMatchObject = {
						a = 10,
						b = "eleven",
					}

					-- When
					local result = matchers.toMatchObject(
						CONTEXT,
						testObject,
						testMatchObject
					)

					-- Then
					assertMatcher.passed(result)
				end
			)

			test(
				"when the received array of objects matches the expected array of objects",
				function()
					-- Given
					local testObjectArray = {
						{
							a = 10,
							b = "eleven",
							c = "quux",
						},

						{
							foo = 85,
							bar = "lest",
						},
					}

					local testMatchObjectArray = {
						{
							a = 10,
							b = "eleven",
						},

						{ bar = "lest" },
					}

					-- When
					local result = matchers.toMatchObject(
						CONTEXT,
						testObjectArray,
						testMatchObjectArray
					)

					-- Then
					assertMatcher.passed(result)
				end
			)
		end)

		describe("should fail", function()
			test(
				"when the received object doesn't matches the expected object",
				function()
					-- Given
					local testObject = {
						a = 10,
						b = "eleven",
						c = "quux",
					}

					local testMatchObject = {
						a = 17,
						b = "twelve",
					}

					-- When
					local result = matchers.toMatchObject(
						CONTEXT,
						testObject,
						testMatchObject
					)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %s to match %s"):format(
							prettyValue(testObject),
							prettyValue(testMatchObject)
						)
					)
				end
			)

			test(
				"when the received array of objects doesn't match the expected array of objects",
				function()
					-- Given
					local testObjectArray = {
						{
							a = 10,
							b = "eleven",
							c = "quux",
						},

						{
							foo = 85,
							bar = "lest",
						},
					}

					local testMatchObjectArray = {
						{
							a = 10,
							b = "eleven",
						},

						{ bar = "lest" },

						{ quux = "fiddle" },
					}

					-- When
					local result = matchers.toMatchObject(
						CONTEXT,
						testObjectArray,
						testMatchObjectArray
					)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %s to match %s"):format(
							prettyValue(testObjectArray),
							prettyValue(testMatchObjectArray)
						)
					)
				end
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local testObject = {
				a = 1,
				finger = "appendage",
			}

			local testMatchObject = {
				a = 1,
			}

			-- When
			local result = matchers.toMatchObject(
				INVERTED_CONTEXT,
				testObject,
				testMatchObject
			)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %s to not match %s"):format(
					prettyValue(testObject),
					prettyValue(testMatchObject)
				)
			)
		end)
	end)
end)
