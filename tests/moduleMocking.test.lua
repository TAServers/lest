local moduleName = "tests.data.moduleToMock"
local invalidModuleName = "this.is.not.real"

it("should mock the module automatically when no factory is passed", function()
	-- When
	lest.mock(moduleName)
	local module = require(moduleName)

	-- Then
	expect(lest.isMockFunction(module.funcs.foo)).toBe(true)
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
