local equality = require("src.matchers.equality")
local prettyValue = require("src.utils.prettyValue")

--- Asserts that a matcher passed
---@param result lest.MatcherResult Result of the matcher
local function assertPass(result)
	assert(result.pass, "test failed when it should have passed!")
end

--- Asserts that a matcher failed
---@param result lest.MatcherResult Result of the matcher
---@param expectedMsg string Expected message of the matcher
local function assertFail(result, expectedMsg)
	assert(result.message == expectedMsg, "test has an incorrect fail message!")
end

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

			assertPass(result)
		end)

		it("should fail when the arguments aren't equal", function()
			local result = equality.toBe(CONTEXT, 2, 42)

			assertFail(result, "Expected 2 to be 42")
		end)

		it(
			"should pass when inverted and the arguments aren't equal",
			function()
				local result = equality.toBe(INVERTED_CONTEXT, 2, 42)
				result.pass = not result.pass

				assertPass(result)
			end
		)

		it("should fail when inverted and the arguments are equal", function()
			local result = equality.toBe(INVERTED_CONTEXT, 2, 2)
			result.pass = not result.pass

			assertFail(result, "Expected 2 to not be 2")
		end)
	end)

	describe("toBeDefined", function()
		it("should pass when defined", function()
			local result = equality.toBeDefined(CONTEXT, 10)

			assertPass(result)
		end)

		it("should fail when undefined", function()
			local result = equality.toBeDefined(CONTEXT, nil)

			assertFail(result, "Expected nil to be defined")
		end)

		it("should pass when inverted and undefined", function()
			local result = equality.toBeDefined(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertPass(result)
		end)

		it("should fail when inverted and defined", function()
			local result = equality.toBeDefined(INVERTED_CONTEXT, 10)
			result.pass = not result.pass

			assertFail(result, "Expected 10 to be undefined")
		end)
	end)

	describe("toBeUndefined", function()
		it("should pass when undefined", function()
			local result = equality.toBeUndefined(CONTEXT, nil)

			assertPass(result)
		end)

		it("should fail when defined", function()
			local result = equality.toBeUndefined(CONTEXT, 10)

			assertFail(result, "Expected 10 to be undefined")
		end)

		it("should pass when inverted and defined", function()
			local result = equality.toBeUndefined(INVERTED_CONTEXT, 10)
			result.pass = not result.pass

			assertPass(result)
		end)

		it("should fail when inverted and undefined", function()
			local result = equality.toBeUndefined(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertFail(result, "Expected nil to be defined")
		end)
	end)

	describe("toEqual", function()
		it("should pass on equality", function()
			local result = equality.toEqual(CONTEXT, 10, 10)

			assertPass(result)
		end)

		it("should fail on inequality", function()
			local result = equality.toEqual(CONTEXT, 10, 15)

			assertFail(result, "Expected 10 to deeply equal 15")
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

			assertPass(result)
		end)

		it("should fail on deep inequality", function()
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

			local result = equality.toEqual(CONTEXT, tableOne, tableTwo)

			assertFail(
				result,
				("Expected %s to deeply equal %s"):format(
					prettyValue(tableOne),
					prettyValue(tableTwo)
				)
			)
		end)

		it("should pass when inverted on inequality", function()
			local result = equality.toEqual(INVERTED_CONTEXT, 5, 10)
			result.pass = not result.pass

			assertPass(result)
		end)

		it("should fail when inverted on equality", function()
			local result = equality.toEqual(INVERTED_CONTEXT, 10, 10)

			assertFail(result, "Expected 10 to not deeply equal 10")
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

			assertPass(result)
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

			assertFail(
				result,
				("Expected %s to not deeply equal %s"):format(
					prettyValue(tableOne),
					prettyValue(tableTwo)
				)
			)
		end)
	end)

	describe("toBeTruthy", function()
		it("should pass on truthy values", function()
			assertPass(equality.toBeTruthy(CONTEXT, true))
		end)

		it("should fail on falsy values", function()
			assertFail(
				equality.toBeTruthy(CONTEXT, false),
				"Expected false to be truthy"
			)
			assertFail(
				equality.toBeTruthy(CONTEXT, nil),
				"Expected nil to be truthy"
			)
		end)

		it("should fail when inverted on truthy values", function()
			local result = equality.toBeTruthy(INVERTED_CONTEXT, true)
			result.pass = not result.pass

			assertFail(result, "Expected true to not be truthy")
		end)

		it("should pass when inverted on falsy values", function()
			local result = equality.toBeTruthy(INVERTED_CONTEXT, false)
			result.pass = not result.pass

			assertPass(result)

			result = equality.toBeTruthy(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertPass(result)
		end)
	end)

	describe("toBeFalsy", function()
		it("should fail on truthy values", function()
			assertFail(
				equality.toBeFalsy(CONTEXT, true),
				"Expected true to be falsy"
			)
		end)

		it("should pass on falsy values", function()
			assertPass(equality.toBeFalsy(CONTEXT, false))
			assertPass(equality.toBeFalsy(CONTEXT, nil))
		end)

		it("should pass when inverted on truthy values", function()
			local result = equality.toBeFalsy(INVERTED_CONTEXT, true)
			result.pass = not result.pass

			assertPass(result)
		end)

		it("should fail when inverted on falsy values", function()
			local result = equality.toBeFalsy(INVERTED_CONTEXT, false)
			result.pass = not result.pass

			assertFail(result, "Expected false to not be falsy")

			result = equality.toBeFalsy(INVERTED_CONTEXT, nil)
			result.pass = not result.pass

			assertFail(result, "Expected nil to not be falsy")
		end)
	end)

	describe("toBeInstanceOf", function()
		local TestClass = {}
		local instance = setmetatable({}, TestClass)

		it("should pass on instances of a class", function()
			assertPass(equality.toBeInstanceOf(CONTEXT, instance, TestClass))
		end)

		it("should fail on non-instances of a class", function()
			local nonInstance = {}
			assertFail(
				equality.toBeInstanceOf(CONTEXT, nonInstance, TestClass),
				("Expected %s to be an instance of %s"):format(
					prettyValue(nonInstance),
					prettyValue(TestClass)
				)
			)
		end)

		it("should fail when inverted on instances of a class", function()
			local result =
				equality.toBeInstanceOf(INVERTED_CONTEXT, instance, TestClass)
			result.pass = not result.pass
			assertFail(
				result,
				("Expected %s to not be an instance of %s"):format(
					prettyValue(instance),
					prettyValue(TestClass)
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

			assertPass(result)
		end)
	end)
end)
