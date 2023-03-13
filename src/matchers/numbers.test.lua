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

		describe("should fail", function()
			test(
				"when the received value is not close to the expected value",
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
						("Expected %.3f to be close to %d (%d decimal places)"):format(
							closeValue,
							testValue,
							numDigits
						)
					)
				end
			)

			test("on infinity for any parameter", function()
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
					("Expected %d to be close to inf (1 decimal places)"):format(
						normalNumber
					)
				)

				assertMatcher.hasMessage(
					resultSwapped,
					("Expected inf to be close to %d (1 decimal places)"):format(
						normalNumber
					)
				)
			end)

			test("on NaN for any parameter", function()
				-- Given
				local normalNumber = 1

				-- When
				local result =
					matchers.toBeCloseTo(CONTEXT, normalNumber, NAN, 1)

				local resultSwapped =
					matchers.toBeCloseTo(CONTEXT, NAN, normalNumber, 1)

				-- Then
				assertMatcher.failed(result)
				assertMatcher.hasMessage(
					result,
					("Expected %d to be close to %s (1 decimal places)"):format(
						normalNumber,
						tostring(NAN)
					)
				)
				assertMatcher.failed(resultSwapped)
				assertMatcher.hasMessage(
					resultSwapped,
					("Expected %s to be close to %d (1 decimal places)"):format(
						tostring(NAN),
						normalNumber
					)
				)
			end)

			test("on infinity and NaN for both parameters", function()
				-- Given
				local negativeInf = -math.huge
				local positiveInf = math.huge

				-- When
				local resultBothInf =
					matchers.toBeCloseTo(CONTEXT, positiveInf, positiveInf)
				local resultPosInfNegInf =
					matchers.toBeCloseTo(CONTEXT, positiveInf, negativeInf)
				local resultBothNegInf =
					matchers.toBeCloseTo(CONTEXT, positiveInf, positiveInf)
				local resultBothNan = matchers.toBeCloseTo(CONTEXT, NAN, NAN)

				-- Then
				assertMatcher.passed(resultBothInf)
				assertMatcher.passed(resultBothNegInf)

				assertMatcher.failed(resultPosInfNegInf)
				assertMatcher.failed(resultBothNan)

				assertMatcher.hasMessage(
					resultPosInfNegInf,
					("Expected %s to be close to %s (2 decimal places)"):format(
						tostring(positiveInf),
						tostring(negativeInf)
					)
				)

				assertMatcher.hasMessage(
					resultBothNan,
					("Expected %s to be close to %s (2 decimal places)"):format(
						tostring(NAN),
						tostring(NAN)
					)
				)
			end)
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
				("Expected %.3f to not be close to %d (1 decimal places)"):format(
					closeValue,
					testValue,
					numDigits
				)
			)
		end)
	end)

	describe("toBeNaN", function()
		it("should pass when the received value is NaN", function()
			-- Given
			local notANumber = 0 / 0

			-- When
			local result = matchers.toBeNaN(CONTEXT, notANumber)

			-- Then
			assertMatcher.passed(result)
		end)

		it("should fail when the received value isn't NaN", function()
			-- Given
			local normalNumber = 1

			-- When
			local result = matchers.toBeNaN(CONTEXT, normalNumber)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be NaN"):format(normalNumber)
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local notANumber = 0 / 0

			-- When
			local result = matchers.toBeNaN(INVERTED_CONTEXT, notANumber)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %s to not be NaN"):format(tostring(notANumber))
			)
		end)
	end)

	describe("toBeInfinity", function()
		it("should pass when the received value is infinity", function()
			-- When
			local resultPositive = matchers.toBeInfinity(CONTEXT, INFINITY)
			local resultNegative = matchers.toBeInfinity(CONTEXT, -INFINITY)

			-- Then
			assertMatcher.passed(resultPositive)
			assertMatcher.passed(resultNegative)
		end)

		it("should fail when the received value isn't infinity", function()
			-- Given
			local normalNumber = 1

			-- When
			local result = matchers.toBeInfinity(CONTEXT, normalNumber)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be infinity"):format(normalNumber)
			)
		end)

		it("should have an inverted message", function()
			-- When
			local result = matchers.toBeInfinity(INVERTED_CONTEXT, INFINITY)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %s to not be infinity"):format(tostring(INFINITY))
			)
		end)
	end)
end)
