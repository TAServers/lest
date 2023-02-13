-- This test suite doesn't rely on the equality matchers since they're being tested. Instead this suite uses
-- basic lua assertions to verify matcher behavior.

local function matcherPassed(fn)
	local passed = pcall(fn)
	return passed
end

describe("equality matchers", function()
	describe("toBe", function()
		it("should pass on equality", function()
			assert(matcherPassed(function()
				expect(2).toBe(2)
			end))
		end)

		it("shouldn't pass on inequality", function()
			assert(not matcherPassed(function()
				expect(2).toBe(4)
			end))
		end)
	end)

	describe("toBeDefined", function()
		it("should pass when defined", function()
			assert(matcherPassed(function()
				expect(20).toBeDefined()
			end))
		end)

		it("shouldn't pass when undefined", function()
			assert(not matcherPassed(function()
				expect(nil).toBeDefined()
			end))
		end)
	end)

	describe("toBeUndefined", function()
		it("should pass when undefined", function()
			assert(matcherPassed(function()
				expect(nil).toBeUndefined()
			end))
		end)

		it("shouldn't pass when defined", function()
			assert(not matcherPassed(function()
				expect(23).toBeUndefined()
			end))
		end)
	end)

	describe("toEqual", function()
		it("should pass on equality", function()
			assert(matcherPassed(function()
				expect(10).toEqual(10)
			end))
		end)

		it("shouldn't error on inequality", function()
			assert(not matcherPassed(function()
				expect(40).toEqual(20)
			end))
		end)

		it("should pass on deep equality", function()
			assert(matcherPassed(function()
				local testTableOne = { a = 2, ["kruger"] = 11 }
				local testTableTwo = { a = 2, ["kruger"] = 11 }

				expect(testTableOne).toEqual(testTableTwo)
			end))
		end)

		it("shouldn't pass on deep inequality", function()
			assert(not matcherPassed(function()
				local testTableOne = { 1337, a = 2, ["kruger"] = 11 }
				local testTableTwo = { a = 2, ["kruger"] = 11 }

				expect(testTableOne).toEqual(testTableTwo)
			end))
		end)
	end)

	describe("toBeTruthy", function()
		it("should pass on truthy values", function()
			assert(matcherPassed(function()
				expect(true).toBeTruthy()
				-- FYI: 1 and 0 are both truthy in Lua unlike other languages.
				expect(1).toBeTruthy()
				expect(0).toBeTruthy()
				expect("").toBeTruthy()
			end))
		end)

		it("shouldn't pass on falsy values", function()
			assert(not matcherPassed(function()
				expect(nil).toBeTruthy()
				expect(false).toBeTruthy()
			end))
		end)
	end)

	describe("toBeFalsy", function()
		it("should pass on falsy values", function()
			assert(matcherPassed(function()
				expect(nil).toBeFalsy()
				expect(false).toBeFalsy()
			end))
		end)

		it("shouldn't pass on truthy values", function()
			assert(not matcherPassed(function()
				expect(true).toBeFalsy()
				expect(1).toBeFalsy()
				expect(0).toBeFalsy()
				expect("").toBeFalsy()
			end))
		end)
	end)

	describe("toBeInstanceOf", function()
		local TestClass = {}
		TestClass.__index = TestClass

		function TestClass.new()
			return setmetatable({ randomMember = 2 }, TestClass)
		end

		it("should pass on instances of a class", function()
			assert(matcherPassed(function()
				expect(TestClass.new()).toBeInstanceOf(TestClass)
			end))
		end)

		it("shouldn't pass on non-instances of a class", function()
			assert(not matcherPassed(function()
				expect({}).toBeInstanceOf(TestClass)
			end))
		end)
	end)
end)
