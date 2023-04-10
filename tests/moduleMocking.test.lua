local testCases = {
	require = {
		importer = require,
		moduleName = "tests.data.moduleToMock",
		secondModuleName = "tests.data.moduleToMock2",
		invalidModuleName = "this.is.not.real",
	},
	loadfile = {
		importer = function(moduleName)
			return loadfile(moduleName)()
		end,
		moduleName = "tests/data/moduleToMock.lua",
		secondModuleName = "tests/data/moduleToMock2.lua",
		invalidModuleName = "this/is/not/real.lua",
	},
	dofile = {
		importer = dofile,
		moduleName = "tests/data/moduleToMock.lua",
		secondModuleName = "tests/data/moduleToMock2.lua",
		invalidModuleName = "this/is/not/real.lua",
	},
}

describe("lest.mock", function()
	describe.each({ "require", "loadfile", "dofile" })(
		"with %s",
		function(importerName)
			local testCase = testCases[importerName]

			local importer = testCase.importer
			local importerActual = importerName == "loadfile"
					and function(moduleName)
						return lest.loadfileActual(moduleName)()
					end
				or lest[importerName .. "Actual"]

			local moduleName = testCase.moduleName
			local secondModuleName = testCase.secondModuleName
			local invalidModuleName = testCase.invalidModuleName

			it(
				"should mock the module automatically when no factory is passed",
				function()
					-- When
					lest.mock(moduleName)
					local module = importer(moduleName)

					-- Then
					expect(lest.isMockFunction(module.funcs.foo)).toBe(true)
				end
			)

			it("should not mock another module", function()
				-- When
				lest.mock(moduleName)
				local module = importer(secondModuleName)

				-- Then
				expect(module.foo).toThrow("Module was not mocked")
			end)

			it(
				"should mock a virtual module when a factory is passed",
				function()
					-- Given
					local virtualModulePath = "not a real module" -- Can't use invalidModuleName as it will affect later tests
					local mockFactoryFn = lest.fn()

					-- When
					lest.mock(virtualModulePath, mockFactoryFn)
					importer(virtualModulePath)

					-- Then
					expect(mockFactoryFn).toHaveBeenCalled()
				end
			)

			it("should call the factory when the module is imported", function()
				-- Given
				local mockFactory = lest.fn()

				-- When
				lest.mock(moduleName, mockFactory)
				importer(moduleName)

				-- Then
				expect(mockFactory).toHaveBeenCalled()
			end)

			it(
				"should not call the factory when a different module is imported",
				function()
					-- Given
					local mockFactory = lest.fn()

					-- When
					lest.mock(moduleName, mockFactory)
					importer(secondModuleName)

					-- Then
					expect(mockFactory).never.toHaveBeenCalled()
				end
			)

			it(
				string.format(
					"should bypass module mocks when using lest.%sActual",
					importerName
				),
				function()
					-- Given
					lest.mock(moduleName)

					-- When
					local foo = importerActual(moduleName).funcs.foo

					-- Then
					expect(foo).toThrow("Module was not mocked")
				end
			)
		end
	)

	it("should cache the auto mocked module when using require", function()
		-- Given
		local mockFn = lest.fn()

		-- When
		lest.mock(testCases.require.moduleName)
		require(testCases.require.moduleName).funcs.foo = mockFn
		require(testCases.require.moduleName).funcs.foo()

		-- Then
		expect(mockFn).toHaveBeenCalled()
	end)

	it("should return only the first export when using require", function()
		-- Given
		lest.mock(testCases.require.moduleName)
		local _, second = require(testCases.require.moduleName)

		-- Then
		expect(second).toBeNil()
	end)

	it("should return all exports when using loadfile", function()
		-- Given
		lest.mock(testCases.loadfile.moduleName)
		local _, second = loadfile(testCases.loadfile.moduleName)()

		-- Then
		expect(second).toBeDefined()
	end)

	it("should return all exports when using dofile", function()
		-- Given
		lest.mock(testCases.dofile.moduleName)
		local _, second = dofile(testCases.dofile.moduleName)

		-- Then
		expect(second).toBeDefined()
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
	describe.each({ "require", "loadfile", "dofile" })(
		"with %s",
		function(importerName)
			local testCase = testCases[importerName]

			local importer = testCase.importer
			local moduleName = testCase.moduleName

			it("should remove the module mock", function()
				-- Given
				lest.mock(moduleName)

				-- When
				lest.removeModuleMock(moduleName)
				local foo = importer(moduleName).funcs.foo

				-- Then
				expect(foo).toThrow("Module was not mocked")
			end)
		end
	)

	it("should throw an error if the module has not been mocked", function()
		-- Given
		local removeMockFn = function()
			lest.removeModuleMock(testCases.require.invalidModuleName)
		end

		-- Then
		expect(removeMockFn).toThrow(
			string.format(
				"Module '%s' has not been mocked",
				testCases.require.invalidModuleName
			)
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
		lest.mock(testCases.require.moduleName)
		lest.mock(testCases.require.secondModuleName)

		-- When
		lest.removeAllModuleMocks()
		local firstModuleFn = require(testCases.require.moduleName).funcs.foo
		local secondModuleFn = require(testCases.require.secondModuleName).foo

		-- Then
		expect(firstModuleFn).toThrow("Module was not mocked")
		expect(secondModuleFn).toThrow("Module was not mocked")
	end)
end)
