local moduleName = "tests.data.moduleToMock"
local secondModuleName = "tests.data.moduleToMock2"
local invalidModuleName = "this.is.not.real"

describe("lest.mock", function()
	it(
		"should mock the module automatically when no factory is passed",
		function()
			-- When
			lest.mock(moduleName)
			local module = require(moduleName)

			-- Then
			expect(lest.isMockFunction(module.funcs.foo)).toBe(true)
		end
	)

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

	it("should mock a virtual module when a factory is passed", function()
		-- Given
		local virtualModulePath = "not a real module" -- Can't use invalidModuleName as it will affect later tests
		local mockFactoryFn = lest.fn()

		-- When
		lest.mock(virtualModulePath, mockFactoryFn)
		require(virtualModulePath)

		-- Then
		expect(mockFactoryFn).toHaveBeenCalled()
	end)

	it("should call the factory when the module is required", function()
		-- Given
		local mockFactory = lest.fn()

		-- When
		lest.mock(moduleName, mockFactory)
		require(moduleName)

		-- Then
		expect(mockFactory).toHaveBeenCalled()
	end)

	it(
		"should not call the factory when a different module is required",
		function()
			-- Given
			local mockFactory = lest.fn()

			-- When
			lest.mock(moduleName, mockFactory)
			require(secondModuleName)

			-- Then
			expect(mockFactory).never.toHaveBeenCalled()
		end
	)

	it("should cache the auto mocked module when using require", function()
		-- Given
		local mockFn = lest.fn()

		-- When
		lest.mock(moduleName)
		require(moduleName).funcs.foo = mockFn
		require(moduleName).funcs.foo()

		-- Then
		expect(mockFn).toHaveBeenCalled()
	end)

	it("should bypass module mocks when using lest.requireActual", function()
		-- Given
		lest.mock(moduleName)

		-- When
		local foo = lest.requireActual(moduleName).funcs.foo

		-- Then
		expect(foo).toThrow("Module was not mocked")
	end)

	describe("argument assertions", function()
		it("should throw when the module name is not a string", function()
			-- Given
			local mockModuleFn = function()
				---@diagnostic disable-next-line: param-type-mismatch
				lest.mock(1234)
			end

			-- Then
			expect(mockModuleFn).toThrow(
				"TypeError: Expected moduleName to be a string"
			)
		end)

		it(
			"should throw when the factory is given and not a function",
			function()
				-- Given
				local mockModuleFn = function()
					---@diagnostic disable-next-line: param-type-mismatch
					lest.mock("", 1234)
				end

				-- Then
				expect(mockModuleFn).toThrow(
					"TypeError: Expected factory to be a function"
				)
			end
		)
	end)
end)

describe("lest.removeModuleMock", function()
	it("should remove the module mock", function()
		-- Given
		lest.mock(moduleName)

		-- When
		lest.removeModuleMock(moduleName)
		local foo = require(moduleName).funcs.foo

		-- Then
		expect(foo).toThrow("Module was not mocked")
	end)

	it("should throw an error if the module has not been mocked", function()
		-- Given
		local removeMockFn = function()
			lest.removeModuleMock(invalidModuleName)
		end

		-- Then
		expect(removeMockFn).toThrow(
			string.format("Module '%s' has not been mocked", invalidModuleName)
		)
	end)

	it("should throw when the module name is not a string", function()
		-- Given
		local removeMockFn = function()
			---@diagnostic disable-next-line: param-type-mismatch
			lest.removeModuleMock(1234)
		end

		-- Then
		expect(removeMockFn).toThrow(
			"TypeError: Expected moduleName to be a string"
		)
	end)
end)

describe("lest.removeAllModuleMocks", function()
	it("should remove all module mocks", function()
		-- Given
		lest.mock(moduleName)
		lest.mock(secondModuleName)

		-- When
		lest.removeAllModuleMocks()
		local firstModuleFn = require(moduleName).funcs.foo
		local secondModuleFn = require(secondModuleName).foo

		-- Then
		expect(firstModuleFn).toThrow("Module was not mocked")
		expect(secondModuleFn).toThrow("Module was not mocked")
	end)
end)
