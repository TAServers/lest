local withTimeout = require("src.lua.utils.timeout")
local TimeoutError = require("src.lua.errors.timeout")

describe("timeout", function()
	it("should succeed when the timeout is not reached", function()
		-- Given
		local func = function(arg)
			return arg
		end
		local arg = "test"

		-- When
		local success, retval = withTimeout(1000, func, arg)

		-- Then
		expect(success).toBe(true)
		expect(retval).toBe(arg)
	end)

	it("should fail when the function errors", function()
		-- Given
		local func = function(arg)
			error(arg)
		end
		local arg = {}

		-- When
		local success, err = withTimeout(1000, func, arg)

		-- Then
		expect(success).toBe(false)
		expect(err).toBe(arg)
	end)

	it("should fail when the timeout is reached", function()
		-- Given
		local func = function()
			while true do
			end
		end

		-- When
		local success, err = withTimeout(0, func, arg)

		-- Then
		expect(success).toBe(false)
		expect(err).toBeInstanceOf(TimeoutError)
	end)

	it(
		"should adjust the timeout with lest.setTimeout while running",
		function()
			-- Given
			local func = function()
				lest.setTimeout(-1)
			end

			-- When
			local success, err = withTimeout(1000, func)

			-- Then
			expect(success).toBe(false)
			expect(err).toBeInstanceOf(TimeoutError)
		end
	)
end)
