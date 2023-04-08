local moduleName = "tests.data.moduleToMock"
local secondModuleName = "tests.data.moduleToMock2"
local invalidModuleName = "this.is.not.real"

it("should mock the module automatically when no factory is passed", function()
	-- When
	lest.mock(moduleName)
	local module = require(moduleName)

	-- Then
	expect(lest.isMockFunction(module.funcs.foo)).toBe(true)
end)

it("should not mock another module", function()
	-- When
	lest.mock(moduleName)
	local module = require(secondModuleName)

	-- Then
	expect(module.foo).toThrow("Module was not mocked")
end)

it(
	"should throw an error when no factory is passed and the module does not exist",
	function()
		-- Given
		local mockModuleFn = function()
			lest.mock(invalidModuleName)
		end

		-- Then
		expect(mockModuleFn).toThrow("module 'this.is.not.real' not found")
	end
)

it("should call the factory when the module is required", function()
	-- Given
	local mockFactory = lest.fn()

	-- When
	lest.mock(moduleName, mockFactory)
	require(moduleName)

	-- Then
	expect(mockFactory).toHaveBeenCalled()
end)

it("should not call the factory when a different module is required", function()
	-- Given
	local mockFactory = lest.fn()

	-- When
	lest.mock(moduleName, mockFactory)
	require(secondModuleName)

	-- Then
	expect(mockFactory).never.toHaveBeenCalled()
end)

it(
	"should return loader data when auto mocking the module with require",
	function()
		-- Given
		local _, expectedLoaderData = require(moduleName)

		-- When
		lest.mock(moduleName)
		local _, receivedLoaderData = require(moduleName)

		-- Then
		expect(expectedLoaderData).toBe("./data/moduleToMock")
		expect(receivedLoaderData).toBe(expectedLoaderData)
	end
)

it(
	"should return loader data when manually mocking the module with require",
	function()
		-- Given
		local _, expectedLoaderData = require(moduleName)

		-- When
		lest.mock(moduleName, function() end)
		local _, receivedLoaderData = require(moduleName)

		-- Then
		expect(expectedLoaderData).toBe("./data/moduleToMock")
		expect(receivedLoaderData).toBe(expectedLoaderData)
	end
)
