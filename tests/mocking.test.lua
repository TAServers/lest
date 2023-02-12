describe("lest.fn", function()
	it("should mock the implementation", function()
		-- Given
		local mockFn = lest.fn()
		local implementation = function() end

		-- When
		mockFn:mockImplementation(implementation)

		-- Then
		expect(mockFn:getMockImplementation()).toBe(implementation)
	end)

	it("should call the mock implementation", function()
		-- Given
		local mockFn = lest.fn(function(arg)
			return arg
		end)
		local expected = 12345

		-- When
		local received = mockFn(expected)

		-- Then
		expect(received).toBe(expected)
	end)

	it("should update mock data when called", function()
		-- Given
		local mockFn = lest.fn(function(arg)
			return arg
		end)
		local expected = 12345

		-- When
		mockFn(expected)

		-- Then
		expect(mockFn.mock.calls[1][1]).toBe(expected)
		expect(mockFn.mock.lastCall).toBe(mockFn.mock.calls[1])
		expect(mockFn.mock.results[1].type).toBe("return")
		expect(mockFn.mock.results[1].value[1]).toBe(expected)
	end)

	it("should mock the implementation once", function()
		-- Given
		local mockFn = lest.fn()

		-- When
		mockFn
			:mockImplementationOnce(function()
				return 1
			end)
			:mockImplementationOnce(function()
				return 2
			end)

		-- Then
		expect(mockFn()).toBe(1)
		expect(mockFn()).toBe(2)
	end)

	it("should mock the return value", function()
		-- Given
		local mockFn = lest.fn()
		local expected = 12345

		-- When
		mockFn:mockReturnValue(expected)

		-- Then
		expect(mockFn()).toBe(expected)
	end)

	it("should mock the return value once", function()
		-- Given
		local mockFn = lest.fn()

		-- When
		mockFn:mockReturnValueOnce(1):mockReturnValueOnce(2)

		-- Then
		expect(mockFn()).toBe(1)
		expect(mockFn()).toBe(2)
	end)

	it("should set the mock's name", function()
		-- Given
		local mockFn = lest.fn()
		local expected = "mockName"

		-- When
		mockFn:mockName(expected)

		-- Then
		expect(mockFn:getMockName()).toBe(expected)
		expect(tostring(mockFn)).toBe(expected)
	end)
end)
