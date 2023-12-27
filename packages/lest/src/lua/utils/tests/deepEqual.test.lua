local deepEqual = require("src.lua.utils.deepEqual")

describe("deepEqual", function()
	describe("should return true", function()
		it("when shallow values are equal", function()
			-- Given
			local a, b = true, true

			-- When
			local received = deepEqual(a, b)

			-- Then
			expect(received).toBe(true)
		end)

		it("when table values are deeply equal", function()
			-- Given
			local a, b =
				{ a = { b = { c = true } } }, { a = { b = { c = true } } }

			-- When
			local received = deepEqual(a, b)

			-- Then
			expect(received).toBe(true)
		end)
	end)

	describe("should return false", function()
		it("when shallow values are not equal", function()
			-- Given
			local a, b = true, false

			-- When
			local received = deepEqual(a, b)

			-- Then
			expect(received).toBe(false)
		end)

		it("when table values are not deeply equal", function()
			-- Given
			local a, b =
				{ a = { b = { c = true } } }, { a = { b = { c = false } } }

			-- When
			local received = deepEqual(a, b)

			-- Then
			expect(received).toBe(false)
		end)
	end)

	it(
		"should not stack overflow when tables contain circular reference",
		function()
			-- Given
			local a, b = { val = 5 }, { val = 5 }

			a.a = a
			b.a = b

			a.key2 = a
			b.key2 = a

			-- When
			local received = deepEqual(a, b)

			-- Then
			expect(received).toBe(true)
		end
	)
end)
