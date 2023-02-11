describe("debug", function()
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

	it("throws an error", function()
		error("This is an error")
	end)
end)
