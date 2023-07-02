local matchers = require("src.lua.matchers.functions")
local assertMatcher = require("src.lua.asserts.matchers")

describe("function matchers", function()
	local CONTEXT = {
		inverted = false,
	}

	local INVERTED_CONTEXT = {
		inverted = true,
	}

	test("toThrow is aliased to toThrowError", function()
		assert(
			matchers.toThrow == matchers.toThrowError,
			"toThrow is not aliased"
		)
	end)

	describe("toThrow", function()
		it("should pass when the function throws", function()
			-- Given
			local func = function()
				error()
			end

			-- When
			local result = matchers.toThrow(CONTEXT, func)

			-- Then
			assertMatcher.passed(result)
		end)

		it(
			"should fail with given message when the function does not throw",
			function()
				-- Given
				local func = function() end

				-- When
				local result = matchers.toThrow(CONTEXT, func)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(result, "Expected function to throw")
			end
		)

		it("should pass when the function throws the given error", function()
			-- Given
			local err = "Some Error: Something went wrong"
			local func = function()
				error(err)
			end

			-- When
			local result = matchers.toThrow(CONTEXT, func, err)

			-- Then
			assertMatcher.passed(result)
		end)

		it(
			"should fail with given message when the function does not throw the given error",
			function()
				-- Given
				local errToThrow = "This is the error"
				local errToExpect = "This is not the error"

				local func = function()
					error(errToThrow)
				end

				-- When
				local result = matchers.toThrow(CONTEXT, func, errToExpect)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(
					result,
					string.format(
						"Expected function to throw %s\nReceived: %s",
						errToExpect,
						"src/lua/matchers/functions.test.lua:71: " .. errToThrow
					)
				)
			end
		)

		it("should return an inverted message", function()
			-- Given
			local errToThrow = "This is the error"
			local errToExpect = "This is not the error"
			local func = function()
				error(errToThrow)
			end

			-- When
			local resultWithoutExpected =
				matchers.toThrow(INVERTED_CONTEXT, func)
			local resultWithExpected =
				matchers.toThrow(INVERTED_CONTEXT, func, errToExpect)

			-- Then
			assertMatcher.hasMessage(
				resultWithoutExpected,
				"Expected function to not throw"
			)
			assertMatcher.hasMessage(
				resultWithExpected,
				string.format(
					"Expected function to not throw %s\nReceived: %s",
					errToExpect,
					"src/lua/matchers/functions.test.lua:95: " .. errToThrow
				)
			)
		end)
	end)
end)
