local matchers = require("src.matchers.functions")

--- Asserts the matcher passed. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertPass(result)
	assert(result.pass, "Expected matcher to pass")
end

--- Asserts the matcher failed. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertFail(result)
	assert(not result.pass, "Expected matcher to fail")
end

--- Asserts the matcher returned the given message. TODO: move this into an asserts file in LEST-46
---@param result lest.MatcherResult
local function assertMessage(result, message)
	assert(
		result.message == message,
		string.format(
			"Expected message: %s\nReceived message: %s",
			message,
			result.message
		)
	)
end

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
			assertPass(result)
		end)

		it(
			"should fail with given message when the function does not throw",
			function()
				-- Given
				local func = function() end

				-- When
				local result = matchers.toThrow(CONTEXT, func)

				-- Then
				assertFail(result)
				assertMessage(result, "Expected function to throw")
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
			assertPass(result)
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
				assertFail(result)
				assertMessage(
					result,
					string.format(
						"Expected function to throw %s\nReceived: %s",
						errToExpect,
						"src/matchers/functions.test.lua:95: " .. errToThrow
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
			assertMessage(
				resultWithoutExpected,
				"Expected function to not throw"
			)
			assertMessage(
				resultWithExpected,
				string.format(
					"Expected function to not throw %s\nReceived: %s",
					errToExpect,
					"src/matchers/functions.test.lua:119: " .. errToThrow
				)
			)
		end)
	end)
end)
