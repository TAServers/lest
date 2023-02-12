beforeEach(function()
	print("Before each global")
end)

afterEach(function()
	print("After each global")
end)

describe("basic", function()
	beforeEach(function()
		print("Before each")
	end)

	beforeAll(function()
		print("Before all")
	end)

	afterEach(function()
		print("After Each")
	end)

	afterAll(function()
		print("After all")
	end)

	it("should pass equality check", function()
		expect(true).toBe(true)
	end)

	it("should pass inverted equality check", function()
		expect(true).never.toBe(false)
	end)

	xit("this test is disabled", function()
		error("This should not run")
	end)

	it("should fail", function()
		expect(true).toBe(false)
	end)

	it("should also fail", function()
		expect(true).never.toBe(true)
	end)

	it("throws an error", function()
		error("This is an error")
	end)
end)

describe("mocking", function()
	local mockedFn = lest.fn(function(arg)
		return arg
	end)

	it("should return arg", function()
		-- Given
		local expected = 12345

		-- When
		local received = mockedFn(expected)

		-- Then
		expect(received).toBe(expected)
	end)

	it("should mock return", function()
		-- Given
		local expected = 12345
		mockedFn:mockReturnValue(expected)

		-- When
		local received = mockedFn()

		-- Then
		expect(received).toBe(expected)
	end)
end)
