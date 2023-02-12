describe("lest.fn", function()
	local mockFn = lest.fn()

	afterEach(function()
		mockFn:mockReset()
	end)

	it("should mock the implementation", function()
		-- Given
		local implementation = function() end

		-- When
		mockFn:mockImplementation(implementation)

		-- Then
		expect(mockFn:getMockImplementation()).toBe(implementation)
	end)

	it("should call the mock implementation", function()
		-- Given
		local mockFnWithConstructorImpl = lest.fn(function(arg)
			return arg
		end)
		local expected = 12345

		-- When
		local received = mockFnWithConstructorImpl(expected)

		-- Then
		expect(received).toBe(expected)
	end)

	it("should update mock data when called", function()
		-- Given
		mockFn:mockImplementation(function(arg)
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
		expect(mockFn.mock.lastResult).toBe(mockFn.mock.results[1])
	end)

	it("should mock the implementation once", function()
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
		local expected = 12345

		-- When
		mockFn:mockReturnValue(expected)

		-- Then
		expect(mockFn()).toBe(expected)
	end)

	it("should mock the return value once", function()
		-- When
		mockFn:mockReturnValueOnce(1):mockReturnValueOnce(2)

		-- Then
		expect(mockFn()).toBe(1)
		expect(mockFn()).toBe(2)
	end)

	it("should set the mock's name", function()
		-- Given
		local expected = "mockName"

		-- When
		mockFn:mockName(expected)

		-- Then
		expect(mockFn:getMockName()).toBe(expected)
		expect(tostring(mockFn)).toBe(expected)
	end)

	describe("clear and reset", function()
		it("should clear any stored calls and results", function()
			-- Given
			mockFn()

			-- When
			mockFn:mockClear()

			-- Then
			expect(mockFn.mock.lastCall).toBeUndefined()
			expect(mockFn.mock.lastResult).toBeUndefined()
			expect(#mockFn.mock.calls).toBe(0)
			expect(#mockFn.mock.results).toBe(0)
		end)

		it("should clear and reset any implementations", function()
			-- Given
			mockFn:mockImplementation(function()
				return "always"
			end)
			mockFn:mockImplementationOnce(function()
				return "once"
			end)

			-- When
			mockFn:mockReset()

			-- Then
			expect(mockFn()).toBeUndefined()
		end)
	end)

	xdescribe("matchers", function()
		it("toHaveBeenCalled should pass", function() end)

		it("toHaveBeenCalledTimes should pass", function() end)

		it("toHaveBeenCalledWith should pass", function() end)

		it("toHaveBeenLastCalledWith should pass", function() end)

		it("toHaveBeenNthCalledWith should pass", function() end)

		it("toHaveReturned should pass", function() end)

		it("toHaveReturnedTimes should pass", function() end)

		it("toHaveReturnedWith should pass", function() end)

		it("toHaveLastReturnedWith should pass", function() end)

		it("toHaveNthReturnedWith should pass", function() end)
	end)
end)

describe("lest.isMockFunction", function()
	it("should return true when the argument is a mock function", function()
		-- Given
		local mockFn = lest.fn()

		-- When
		local received = lest.isMockFunction(mockFn)

		-- Then
		expect(received).toBe(true)
	end)

	it("should return false when the argument is a normal function", function()
		-- Given
		local normalFn = function() end

		-- When
		local received = lest.isMockFunction(normalFn)

		-- Then
		expect(received).toBe(false)
	end)
end)
