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

	it("should mock with chaining", function()
		-- Given
		local classInstance = { chainedMethod = mockFn }

		-- When
		mockFn:mockReturnThis()

		-- Then
		expect(classInstance:chainedMethod():chainedMethod()).toBe(
			classInstance
		)
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
			mockFn
				:mockImplementation(function()
					return "always"
				end)
				:mockImplementationOnce(function()
					return "once"
				end)

			-- When
			mockFn:mockReset()

			-- Then
			expect(mockFn()).toBeUndefined()
		end)
	end)

	describe("matchers", function()
		it("toHaveBeenCalled should pass", function()
			-- Given
			expect(mockFn).never.toHaveBeenCalled()

			-- When
			mockFn()

			-- Then
			expect(mockFn).toHaveBeenCalled()
		end)

		it("toHaveBeenCalledTimes should pass", function()
			-- Given
			expect(mockFn).toHaveBeenCalledTimes(0)
			expect(mockFn).never.toHaveBeenCalledTimes(3)

			-- When
			mockFn()
			mockFn()
			mockFn()

			-- Then
			expect(mockFn).toHaveBeenCalledTimes(3)
		end)

		it("toHaveBeenCalledWith should pass", function()
			-- Given
			expect(mockFn).never.toHaveBeenCalledWith(1, 2, 3, 4)

			-- When
			mockFn("first call")
			mockFn(1, 2, 3, 4)
			mockFn("last call")

			-- Then
			expect(mockFn).toHaveBeenCalledWith(1, 2, 3, 4)
		end)

		it("toHaveBeenLastCalledWith should pass", function()
			-- Given
			expect(mockFn).never.toHaveBeenLastCalledWith(1, 2, 3, 4)

			-- When
			mockFn("first call")
			mockFn(1, 2, 3, 4)

			-- Then
			expect(mockFn).toHaveBeenLastCalledWith(1, 2, 3, 4)
		end)

		it("toHaveBeenNthCalledWith should pass", function()
			-- Given
			expect(mockFn).never.toHaveBeenNthCalledWith(2, "second call", 2, 3)

			-- When
			mockFn("first call")
			mockFn("second call", 2, 3)
			mockFn("third call")

			-- Then
			expect(mockFn).toHaveBeenNthCalledWith(1, "first call")
			expect(mockFn).toHaveBeenNthCalledWith(2, "second call", 2, 3)
			expect(mockFn).toHaveBeenNthCalledWith(3, "third call")
		end)

		it("toHaveReturned should pass", function()
			-- Given
			expect(mockFn).never.toHaveReturned()

			-- When
			mockFn()

			-- Then
			expect(mockFn).toHaveReturned()
		end)

		it("toHaveReturnedTimes should pass", function()
			-- Given
			expect(mockFn).toHaveReturnedTimes(0)
			expect(mockFn).never.toHaveReturnedTimes(3)

			-- When
			mockFn()
			mockFn()
			mockFn()

			-- Then
			expect(mockFn).toHaveReturnedTimes(3)
		end)

		it("toHaveReturnedWith should pass", function()
			-- Given
			mockFn
				:mockReturnValueOnce("first call")
				:mockReturnValueOnce(1, 2, 3, 4)
				:mockReturnValueOnce("last call")

			expect(mockFn).never.toHaveReturnedWith(1, 2, 3, 4)

			-- When
			mockFn()
			mockFn()
			mockFn()

			-- Then
			expect(mockFn).toHaveReturnedWith(1, 2, 3, 4)
		end)

		it("toHaveLastReturnedWith should pass", function()
			-- Given
			mockFn
				:mockReturnValueOnce("first call")
				:mockReturnValueOnce(1, 2, 3, 4)

			expect(mockFn).never.toHaveLastReturnedWith(1, 2, 3, 4)

			-- When
			mockFn()
			mockFn()

			-- Then
			expect(mockFn).toHaveLastReturnedWith(1, 2, 3, 4)
		end)

		it("toHaveNthReturnedWith should pass", function()
			-- Given
			mockFn
				:mockReturnValueOnce("first call")
				:mockReturnValueOnce("second call", 2, 3)
				:mockReturnValueOnce("third call")

			expect(mockFn).never.toHaveNthReturnedWith(2, "second call", 2, 3)

			-- When
			mockFn("first call")
			mockFn("second call", 2, 3)
			mockFn("third call")

			-- Then
			expect(mockFn).toHaveNthReturnedWith(1, "first call")
			expect(mockFn).toHaveNthReturnedWith(2, "second call", 2, 3)
			expect(mockFn).toHaveNthReturnedWith(3, "third call")
		end)
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

describe("lest.clear/resetAllMocks", function()
	it("should clear all mocks", function()
		-- Given
		local mockFns = { lest.fn(), lest.fn() }
		for _, mockFn in ipairs(mockFns) do
			mockFn()
		end

		-- When
		lest.clearAllMocks()

		-- Then
		for _, mockFn in ipairs(mockFns) do
			expect(mockFn.mock.lastCall).toBeUndefined()
			expect(mockFn.mock.lastResult).toBeUndefined()
			expect(#mockFn.mock.calls).toBe(0)
			expect(#mockFn.mock.results).toBe(0)
		end
	end)

	it("should reset all mocks", function()
		-- Given
		local mockFns = {
			lest.fn()
				:mockImplementation(function()
					return "always"
				end)
				:mockImplementationOnce(function()
					return "once"
				end),
			lest.fn()
				:mockImplementation(function()
					return "always"
				end)
				:mockImplementationOnce(function()
					return "once"
				end),
		}
		for _, mockFn in ipairs(mockFns) do
			mockFn()
		end

		-- When
		lest.resetAllMocks()

		-- Then
		for _, mockFn in ipairs(mockFns) do
			expect(mockFn()).toBeUndefined()
		end
	end)
end)
