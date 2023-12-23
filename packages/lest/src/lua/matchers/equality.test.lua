local equality = require("src.lua.matchers.equality")
local serialiseValue = require("utils.serialise-value")
local assertMatcher = require("asserts.matchers")

local CONTEXT = {
	inverted = false,
}

local INVERTED_CONTEXT = {
	inverted = true,
}

describe("equality matchers", function()
	describe("toBe", function()
		it("should pass when the arguments are equal", function()
			local result = equality.toBe(CONTEXT, 2, 2)

			assertMatcher.passed(result)
		end)

		it("should fail when the arguments aren't equal", function()
			local result = equality.toBe(CONTEXT, 2, 42)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected 2 to be 42")
		end)

		it(
			"should pass when inverted and the arguments aren't equal",
			function()
				local result = equality.toBe(INVERTED_CONTEXT, 2, 42)
				result.pass = not result.pass

				assertMatcher.passed(result)
			end
		)

		it("should fail when inverted and the arguments are equal", function()
			local result = equality.toBe(INVERTED_CONTEXT, 2, 2)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected 2 to not be 2")
		end)
	end)

	describe("toBeDefined", function()
		it("should pass when defined", function()
			local result = equality.toBeDefined(CONTEXT, 10)

			assertMatcher.passed(result)
		end)

		it("should fail when undefined", function()
			local result = equality.toBeDefined(CONTEXT, nil)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected nil to be defined")
		end)

		it("should pass when inverted and undefined", function()
			local result = equality.toBeDefined(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertMatcher.passed(result)
		end)

		it("should fail when inverted and defined", function()
			local result = equality.toBeDefined(INVERTED_CONTEXT, 10)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected 10 to be undefined")
		end)
	end)

	describe("toBeUndefined", function()
		it("should pass when undefined", function()
			local result = equality.toBeUndefined(CONTEXT, nil)

			assertMatcher.passed(result)
		end)

		it("should fail when defined", function()
			local result = equality.toBeUndefined(CONTEXT, 10)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected 10 to be undefined")
		end)

		it("should pass when inverted and defined", function()
			local result = equality.toBeUndefined(INVERTED_CONTEXT, 10)
			result.pass = not result.pass

			assertMatcher.passed(result)
		end)

		it("should fail when inverted and undefined", function()
			local result = equality.toBeUndefined(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected nil to be defined")
		end)
	end)

	describe("toEqual", function()
		it("should pass on equality", function()
			local result = equality.toEqual(CONTEXT, 10, 10)

			assertMatcher.passed(result)
		end)

		it("should fail on inequality", function()
			local result = equality.toEqual(CONTEXT, 10, 15)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected: 15\nReceived: 10")
		end)

		it("should pass on deep equality", function()
			local tableOne = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
				},
			}

			local tableTwo = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
				},
			}

			local result = equality.toEqual(CONTEXT, tableOne, tableTwo)

			assertMatcher.passed(result)
		end)

		it("should fail on deep inequality", function()
			local received = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
					"I'm not supposed to be here",
				},
			}

			local expected = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
				},
			}

			local result = equality.toEqual(CONTEXT, received, expected)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				[[- Expected  - 0
+ Received  + 1

  Table {
    Table {
      12,
      14,
      18,
+     "I'm not supposed to be here",
    },
    hi = 10,
    turing = "alan",
  }]]
			)
		end)

		it("should pass when inverted on inequality", function()
			local result = equality.toEqual(INVERTED_CONTEXT, 5, 10)
			result.pass = not result.pass

			assertMatcher.passed(result)
		end)

		it("should fail when inverted on equality", function()
			local result = equality.toEqual(INVERTED_CONTEXT, 10, 10)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected: not 10")
		end)

		it("should pass when inverted on deep inequality", function()
			local tableOne = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
				},
			}

			local tableTwo = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
					"I'm not supposed to be here",
				},
			}

			local result =
				equality.toEqual(INVERTED_CONTEXT, tableOne, tableTwo)
			result.pass = not result.pass

			assertMatcher.passed(result)
		end)

		it("should fail when inverted on deep equality", function()
			local tableOne = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
				},
			}

			local tableTwo = {
				hi = 10,
				["turing"] = "alan",
				{
					12,
					14,
					18,
				},
			}

			local result =
				equality.toEqual(INVERTED_CONTEXT, tableOne, tableTwo)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected: not %s"):format(serialiseValue(tableTwo))
			)
		end)
	end)

	describe("toBeTruthy", function()
		it("should pass on truthy values", function()
			assertMatcher.passed(equality.toBeTruthy(CONTEXT, true))
		end)

		it("should fail on falsy values", function()
			local resultFalse = equality.toBeTruthy(CONTEXT, false)
			local resultNil = equality.toBeTruthy(CONTEXT, nil)

			assertMatcher.failed(resultFalse)
			assertMatcher.hasMessage(resultFalse, "Expected false to be truthy")
			assertMatcher.failed(resultNil)
			assertMatcher.hasMessage(resultNil, "Expected nil to be truthy")
		end)

		it("should fail when inverted on truthy values", function()
			local result = equality.toBeTruthy(INVERTED_CONTEXT, true)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected true to not be truthy")
		end)

		it("should pass when inverted on falsy values", function()
			local result = equality.toBeTruthy(INVERTED_CONTEXT, false)
			result.pass = not result.pass

			assertMatcher.passed(result)

			result = equality.toBeTruthy(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertMatcher.passed(result)
		end)
	end)

	describe("toBeFalsy", function()
		it("should fail on truthy values", function()
			local result = equality.toBeFalsy(CONTEXT, true)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected true to be falsy")
		end)

		it("should pass on falsy values", function()
			assertMatcher.passed(equality.toBeFalsy(CONTEXT, false))
			assertMatcher.passed(equality.toBeFalsy(CONTEXT, nil))
		end)

		it("should pass when inverted on truthy values", function()
			local result = equality.toBeFalsy(INVERTED_CONTEXT, true)
			result.pass = not result.pass

			assertMatcher.passed(result)
		end)

		it("should fail when inverted on falsy values", function()
			local result = equality.toBeFalsy(INVERTED_CONTEXT, false)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected false to not be falsy")

			result = equality.toBeFalsy(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(result, "Expected nil to not be falsy")
		end)
	end)

	describe("toBeInstanceOf", function()
		local TestClass = {}
		local instance = setmetatable({}, TestClass)

		it("should pass on instances of a class", function()
			assertMatcher.passed(
				equality.toBeInstanceOf(CONTEXT, instance, TestClass)
			)
		end)

		it("should fail on non-instances of a class", function()
			local nonInstance = {}

			local result =
				equality.toBeInstanceOf(CONTEXT, nonInstance, TestClass)

			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %s to be an instance of %s"):format(
					serialiseValue(nonInstance),
					serialiseValue(TestClass)
				)
			)
		end)

		it("should fail when inverted on instances of a class", function()
			local result =
				equality.toBeInstanceOf(INVERTED_CONTEXT, instance, TestClass)
			result.pass = not result.pass

			assertMatcher.failed(result)
			assertMatcher.hasMessage(
				result,
				("Expected %s to not be an instance of %s"):format(
					serialiseValue(instance),
					serialiseValue(TestClass)
				)
			)
		end)

		it("should pass when inverted on non-instances of a class", function()
			local nonInstance = {}
			local result = equality.toBeInstanceOf(
				INVERTED_CONTEXT,
				nonInstance,
				TestClass
			)

			result.pass = not result.pass

			assertMatcher.passed(result)
		end)
	end)
end)
