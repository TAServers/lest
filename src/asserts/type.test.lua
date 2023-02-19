local assertType = require("src.asserts.type")

-- TODO: LEST-27
xdescribe("assertType", function()
	it("should succeed when type(object) equals the given string", function()
		-- Given
		local type = "table"
		local object = {}

		-- Then
		expect(function()
			assertType(object, type)
		end).never.toThrow()
	end)

	it(
		"should succeed when getmetatable(object) equals the given table",
		function()
			-- Given
			local meta = {}
			local object = setmetatable({}, meta)

			-- Then
			expect(function()
				assertType(object, meta)
			end).never.toThrow()
		end
	)

	it(
		"should fail when the given type is neither a string nor a table",
		function()
			-- Given
			local type = 1234
			local object = {}

			-- Then
			expect(function()
				assertType(object, type)
			end).toThrow(
				"TypeError: typeStringOrMeta must be either a string or a table"
			)
		end
	)

	it(
		"should fail when type(object) does not equal the given string",
		function()
			-- Given
			local type = "number"
			local object = 1234

			-- Then
			expect(function()
				assertType(object, type)
			end).toThrow(
				'TypeError: Expected 1234 to be an instance of "number"'
			)
		end
	)

	it(
		"should fail when getmetatable(object) does not equal the given table",
		function()
			-- Given
			local meta = setmetatable({}, {
				__tostring = function()
					return "SomeMetatable"
				end,
			})
			local object = 1234

			-- Then
			expect(function()
				assertType(object, meta)
			end).toThrow(
				"TypeError: Expected 1234 to have metatable SomeMetatable"
			)
		end
	)
end)
