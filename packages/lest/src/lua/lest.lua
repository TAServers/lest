require("src.lua.mocking")

local cli = require("src.lua.cli")
local filesInFolder = require("src.lua.utils.filesInFolder")
local runtime = require("src.lua.runtime")
local prettyPrint = require("src.lua.prettyprint")

local options = cli(arg)
local config = dofile(options.config)

local files = filesInFolder()
local testFiles, testFilesCount = {}, 0
for _, filepath in ipairs(files) do
	for _, pattern in ipairs(config.testMatch) do
		if string.find(filepath, pattern) then
			testFilesCount = testFilesCount + 1
			testFiles[testFilesCount] = filepath

			break
		end
	end
end

if options.testTimeout then
	runtime.setDefaultTimeout(options.testTimeout)
elseif config.testTimeout then
	runtime.setDefaultTimeout(config.testTimeout)
end

local tests = runtime.findTests(testFiles)
local success, results = runtime.runTests(tests)

prettyPrint(results)

os.exit(success and 0 or 1)
