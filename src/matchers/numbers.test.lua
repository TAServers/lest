local matchers = require("src.matchers.numbers")
local assertMatcher = require("src.asserts.matchers")

local INFINITY = math.huge
local NAN = 0 / 0

describe("number matchers", function()
	local CONTEXT = {
		inverted = false,
	}

	local INVERTED_CONTEXT = {
		inverted = true,
	}

	describe("toBeCloseTo", function()
		local closeValue = 2.005
		local testValue = 2

		it(
			"should pass when the received value is close to expected value",
			function()
				-- Given
				local numDigits = 1

				-- When
				local result = matchers.toBeCloseTo(
					CONTEXT,
					closeValue,
					testValue,
					numDigits
				)

				-- Then
				assertMatcher.passed(result)
			end
		)

		it(
			"should fail when the received value is not close to the expected value",
			function()
				-- Given
				local numDigits = 3

				-- When
				local result = matchers.toBeCloseTo(
					CONTEXT,
					closeValue,
					testValue,
					numDigits
				)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(
					result,
					("Expected %.3f to be close to %d within %d digits"):format(
						closeValue,
						testValue,
						numDigits
					)
				)
			end
		)

		it("should fail on infinity for any parameter", function()
			-- Given
			local normalNumber = 1

			-- When
			local result =
				matchers.toBeCloseTo(CONTEXT, normalNumber, INFINITY, 1)

			local resultSwapped =
				matchers.toBeCloseTo(CONTEXT, INFINITY, normalNumber, 1)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be close to inf within 1 digits"):format(
					normalNumber
				)
			)

			assertMatcher.hasMessage(
				resultSwapped,
				("Expected inf to be close to %d within 1 digits"):format(
					normalNumber
				)
			)
		end)

		it("should fail on NaN for any parameter", function()
			-- Given
			local normalNumber = 1

			-- When
			local result = matchers.toBeCloseTo(CONTEXT, normalNumber, NAN, 1)

			local resultSwapped =
				matchers.toBeCloseTo(CONTEXT, NAN, normalNumber, 1)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be close to nan within 1 digits"):format(
					normalNumber
				)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected nan to be close to %d within 1 digits"):format(
					normalNumber
				)
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local numDigits = 1

			-- When
			local result = matchers.toBeCloseTo(
				INVERTED_CONTEXT,
				closeValue,
				testValue,
				numDigits
			)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %.3f to not be close to %d within 1 digits"):format(
					closeValue,
					testValue,
					numDigits
				)
			)
		end)
	end)

	describe("toBeGreaterThan", function()
		-- Given
		local greaterNumber = 10
		local smallerNumber = 1

		it(
			"should pass when the received value is greater than the expected value",
			function()
				-- When
				local result = matchers.toBeGreaterThan(
					CONTEXT,
					greaterNumber,
					smallerNumber
				)

				-- Then
				assertMatcher.passed(result)
			end
		)

		it(
			"should fail when the received value is less than the expected value",
			function()
				-- When
				local result = matchers.toBeGreaterThan(
					CONTEXT,
					smallerNumber,
					greaterNumber
				)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(
					result,
					("Expected %d to be greater than %d"):format(
						smallerNumber,
						greaterNumber
					)
				)
			end
		)

		it("should fail on NaN for any parameter", function()
			-- Given
			local normalNumber = 1

			-- When
			local result = matchers.toBeGreaterThan(CONTEXT, normalNumber, NAN)

			local resultSwapped =
				matchers.toBeGreaterThan(CONTEXT, NAN, normalNumber)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be greater than nan"):format(normalNumber)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected nan to be greater than %d"):format(normalNumber)
			)
		end)

		it("should have an inverted message", function()
			-- When
			local result = matchers.toBeGreaterThan(
				INVERTED_CONTEXT,
				greaterNumber,
				smallerNumber
			)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %d to not be greater than %d"):format(
					greaterNumber,
					smallerNumber
				)
			)
		end)
	end)
end)
