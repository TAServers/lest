local matchers = require("src.lua.matchers.numbers")
local assertMatcher = require("src.lua.asserts.matchers")

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
					matchers.toBeCloseTo(CONTEXT, normalNumber, math.huge, 1)

				local resultSwapped =
					matchers.toBeCloseTo(CONTEXT, math.huge, normalNumber, 1)

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
					("Expected %d to be close to NaN (1 decimal places)"):format(
						normalNumber
					)
				)
				assertMatcher.failed(resultSwapped)
				assertMatcher.hasMessage(
					resultSwapped,
					("Expected NaN to be close to %d (1 decimal places)"):format(
						normalNumber
					)
				)
			end)

			test("on infinity and NaN for both parameters", function()
				-- When
				local resultBothInf =
					matchers.toBeCloseTo(CONTEXT, math.huge, math.huge)
				local resultPosInfNegInf =
					matchers.toBeCloseTo(CONTEXT, math.huge, -math.huge)
				local resultBothNegInf =
					matchers.toBeCloseTo(CONTEXT, -math.huge, -math.huge)
				local resultBothNan = matchers.toBeCloseTo(CONTEXT, NAN, NAN)

				-- Then
				assertMatcher.passed(resultBothInf)
				assertMatcher.passed(resultBothNegInf)

				assertMatcher.failed(resultPosInfNegInf)
				assertMatcher.failed(resultBothNan)

				assertMatcher.hasMessage(
					resultPosInfNegInf,
					"Expected inf to be close to -inf (2 decimal places)"
				)

				assertMatcher.hasMessage(
					resultBothNan,
					"Expected NaN to be close to NaN (2 decimal places)"
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

	describe("toBeGreaterThan", function()
		it(
			"should pass when the received value is greater than the expected value",
			function()
				-- Given
				local greaterNumber = 10
				local smallerNumber = 1

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

		describe("should fail", function()
			test(
				"when the received value is less than the expected value",
				function()
					-- Given
					local greaterNumber = 10
					local smallerNumber = 5

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
		end)

		it("should have an inverted message", function()
			-- Given
			local greaterNumber = 10
			local smallerNumber = 1

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

	describe("toBeGreaterThanOrEqual", function()
		it(
			"should pass when the received value is greater than or equal to the expected value",
			function()
				-- Given
				local greaterNumber = 10
				local smallerNumber = 1
				local equalNumber = greaterNumber

				-- When
				local result = matchers.toBeGreaterThanOrEqual(
					CONTEXT,
					greaterNumber,
					smallerNumber
				)

				-- Then
				assertMatcher.passed(result)

				-- When
				local resultEqual = matchers.toBeGreaterThanOrEqual(
					CONTEXT,
					greaterNumber,
					equalNumber
				)

				-- Then
				assertMatcher.passed(resultEqual)
			end
		)

		describe("should fail", function()
			test(
				"when the received value is less than the expected value",
				function()
					-- Given
					local greaterNumber = 10
					local smallerNumber = 3

					-- When
					local result = matchers.toBeGreaterThanOrEqual(
						CONTEXT,
						smallerNumber,
						greaterNumber
					)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %d to be greater than or equal to %d"):format(
							smallerNumber,
							greaterNumber
						)
					)
				end
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local greaterNumber = 10
			local smallerNumber = 2
			-- When
			local result = matchers.toBeGreaterThanOrEqual(
				INVERTED_CONTEXT,
				greaterNumber,
				smallerNumber
			)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %d to not be greater than or equal to %d"):format(
					greaterNumber,
					smallerNumber
				)
			)
		end)
	end)

	describe("toBeLessThan", function()
		it(
			"should pass when the received value is less than the expected value",
			function()
				-- Given
				local greaterNumber = 10
				local smallerNumber = 1

				-- When
				local result =
					matchers.toBeLessThan(CONTEXT, smallerNumber, greaterNumber)

				-- Then
				assertMatcher.passed(result)
			end
		)

		describe("should fail", function()
			test(
				"when the received value is greater than the expected value",
				function()
					-- Given
					local greaterNumber = 10
					local smallerNumber = 5

					-- When
					local result = matchers.toBeLessThan(
						CONTEXT,
						greaterNumber,
						smallerNumber
					)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %d to be less than %d"):format(
							greaterNumber,
							smallerNumber
						)
					)
				end
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local greaterNumber = 10
			local smallerNumber = 1

			-- When
			local result = matchers.toBeLessThan(
				INVERTED_CONTEXT,
				greaterNumber,
				smallerNumber
			)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %d to not be less than %d"):format(
					greaterNumber,
					smallerNumber
				)
			)
		end)
	end)

	describe("toBeLessThanOrEqual", function()
		it(
			"should pass when the received value is less than or equal to the expected value",
			function()
				-- Given
				local greaterNumber = 10
				local smallerNumber = 1
				local equalNumber = greaterNumber

				-- When
				local result = matchers.toBeLessThanOrEqual(
					CONTEXT,
					smallerNumber,
					greaterNumber
				)

				-- Then
				assertMatcher.passed(result)

				-- When
				local resultEqual = matchers.toBeLessThanOrEqual(
					CONTEXT,
					greaterNumber,
					equalNumber
				)

				-- Then
				assertMatcher.passed(resultEqual)
			end
		)

		describe("should fail", function()
			test(
				"when the received value is greater than the expected value",
				function()
					-- Given
					local greaterNumber = 10
					local smallerNumber = 3

					-- When
					local result = matchers.toBeLessThanOrEqual(
						CONTEXT,
						greaterNumber,
						smallerNumber
					)

					-- Then
					assertMatcher.failed(result)
					assertMatcher.hasMessage(
						result,
						("Expected %d to be less than or equal to %d"):format(
							greaterNumber,
							smallerNumber
						)
					)
				end
			)
		end)

		it("should have an inverted message", function()
			-- Given
			local greaterNumber = 10
			local smallerNumber = 2
			-- When
			local result = matchers.toBeLessThanOrEqual(
				INVERTED_CONTEXT,
				greaterNumber,
				smallerNumber
			)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %d to not be less than or equal to %d"):format(
					greaterNumber,
					smallerNumber
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
			-- When
			local result = matchers.toBeNaN(INVERTED_CONTEXT, NAN)

			-- Then
			assertMatcher.hasMessage(result, "Expected NaN to not be NaN")
		end)
	end)

	describe("toBeInfinity", function()
		it("should pass when the received value is infinity", function()
			-- When
			local resultPositive = matchers.toBeInfinity(CONTEXT, math.huge)
			local resultNegative = matchers.toBeInfinity(CONTEXT, -math.huge)

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
			local result = matchers.toBeInfinity(INVERTED_CONTEXT, math.huge)

			-- Then
			assertMatcher.hasMessage(result, "Expected inf to not be infinity")
		end)
	end)
end)
