require("src.mocking")

local cli = require("src.cli")
local filesInFolder = require("src.utils.filesInFolder")
local runtime = require("src.runtime")
local printTable = require("src.utils.printTable")

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

local results = runtime(testFiles)
printTable(results, 5)
