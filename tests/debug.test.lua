describe("debug", function()
	it("should pass equality check", function()
		expect(1):toBe(1)
	end)

	xit("this test is disabled", function()
		error("This should not run")
	end)
end)
