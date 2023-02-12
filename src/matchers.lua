local tablex = require("src.utils.tablex")

local equality = require("src.matchers.equality")
local functions = require("src.matchers.functions")
local mocks = require("src.matchers.mocks")
local numbers = require("src.matchers.numbers")
local strings = require("src.matchers.strings")
local tables = require("src.matchers.tables")

---@type table<string, lest.Matcher>
local matchers =
	tablex.merge(equality, functions, mocks, numbers, strings, tables)

return matchers
