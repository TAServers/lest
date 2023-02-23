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
				("Expected %d to be close to %s within 1 digits"):format(
					normalNumber,
					tostring(NAN)
				)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected %s to be close to %d within 1 digits"):format(
					tostring(NAN),
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

		it(
			"should fail when the received value is less than the expected value",
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
				("Expected %d to be greater than %s"):format(
					normalNumber,
					tostring(NAN)
				)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected %s to be greater than %d"):format(
					tostring(NAN),
					normalNumber
				)
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

		it(
			"should fail when the received value is less than the expected value",
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

		it("should fail on NaN for any parameter", function()
			-- Given
			local normalNumber = 1

			-- When
			local result =
				matchers.toBeGreaterThanOrEqual(CONTEXT, normalNumber, NAN)

			local resultSwapped =
				matchers.toBeGreaterThanOrEqual(CONTEXT, NAN, normalNumber)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be greater than or equal to %s"):format(
					normalNumber,
					tostring(NAN)
				)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected %s to be greater than or equal to %d"):format(
					tostring(NAN),
					normalNumber
				)
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

		it(
			"should fail when the received value is greater than the expected value",
			function()
				-- Given
				local greaterNumber = 10
				local smallerNumber = 5

				-- When
				local result =
					matchers.toBeLessThan(CONTEXT, greaterNumber, smallerNumber)

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

		it("should fail on NaN for any parameter", function()
			-- Given
			local normalNumber = 1

			-- When
			local result = matchers.toBeLessThan(CONTEXT, normalNumber, NAN)

			local resultSwapped =
				matchers.toBeLessThan(CONTEXT, NAN, normalNumber)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be less than %s"):format(
					normalNumber,
					tostring(NAN)
				)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected %s to be less than %d"):format(
					tostring(NAN),
					normalNumber
				)
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

		it(
			"should fail when the received value is greater than the expected value",
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

		it("should fail on NaN for any parameter", function()
			-- Given
			local normalNumber = 1

			-- When
			local result =
				matchers.toBeLessThanOrEqual(CONTEXT, normalNumber, NAN)

			local resultSwapped =
				matchers.toBeLessThanOrEqual(CONTEXT, NAN, normalNumber)

			-- Then
			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %d to be less than or equal to %s"):format(
					normalNumber,
					tostring(NAN)
				)
			)
			assertMatcher.failed(resultSwapped)
			assertMatcher.hasMessage(
				resultSwapped,
				("Expected %s to be less than or equal to %d"):format(
					tostring(NAN),
					normalNumber
				)
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
			-- Given
			local inf = math.huge

			-- When
			local result = matchers.toBeInfinity(CONTEXT, inf)

			-- Then
			assertMatcher.passed(result)
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
			-- Given
			local inf = math.huge

			-- When
			local result = matchers.toBeInfinity(INVERTED_CONTEXT, inf)

			-- Then
			assertMatcher.hasMessage(
				result,
				("Expected %s to not be infinity"):format(tostring(inf))
			)
		end)
	end)
end)
