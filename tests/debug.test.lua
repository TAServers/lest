beforeEach(function()
	print("Before each global")
end)

afterEach(function()
	print("After each global")
end)

describe("debug", function()
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
