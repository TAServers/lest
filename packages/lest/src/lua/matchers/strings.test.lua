local matchers = require("matchers.strings")
local assertMatcher = require("asserts.matchers")
local serialiseValue = require("utils.serialise-value")

describe("string matchers", function()
	local CONTEXT = {
		inverted = false,
	}

	local INVERTED_CONTEXT = {
		inverted = true,
	}

	describe("toMatch", function()
		describe("should pass", function()
			test(
				"when the received string matches the expected pattern",
				function()
					-- Given
					local testString = "hello world"
					local testPattern = "%s"

					-- When
					local result =
						matchers.toMatch(CONTEXT, testString, testPattern)

					-- Then
					assertMatcher.passed(result)
				end
			)

			test(
				"when the received string matches the expected substring",
				function()
					-- Given
					local testString = "hello world"
					local testPattern = "world"

					-- When
					local result =
						matchers.toMatch(CONTEXT, testString, testPattern)

					-- Then
					assertMatcher.passed(result)
				end
			)
		end)

		describe("should fail", function()
			test(
				"when the received string doesn't match the expected pattern",
				function()
					-- Given
					local testString = "hello world"
					local testPattern = "/+"

					-- When
					local result =
						matchers.toMatch(CONTEXT, testString, testPattern)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %s to match %s"):format(
							serialiseValue(testString),
							serialiseValue(testPattern)
						)
					)
				end
			)

			test(
				"when the received string doesn't match the expected substring",
				function()
					-- Given
					local testString = "hello world"
					local testPattern = "among us"

					-- When
					local result =
						matchers.toMatch(CONTEXT, testString, testPattern)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %s to match %s"):format(
							serialiseValue(testString),
							serialiseValue(testPattern)
						)
					)
				end
			)

			test("when the received object is not a string", function()
				-- Given
				local invalidObject = { 10 }
				local testString = "Hi"

				-- When
				local result =
					matchers.toMatch(CONTEXT, invalidObject, testString)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(
					result,
					("Expected %s to match %s"):format(
						serialiseValue(invalidObject),
						serialiseValue(testString)
					)
				)
			end)
		end)

		it("should have inverted message", function()
			-- Given
			local testString = "club"
			local testPattern = ".+"

			-- When
			local result =
				matchers.toMatch(INVERTED_CONTEXT, testString, testPattern)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %s to not match %s"):format(
					serialiseValue(testString),
					serialiseValue(testPattern)
				)
			)
		end)
	end)
end)
