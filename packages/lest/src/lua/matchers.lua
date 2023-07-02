local tablex = require("src.lua.utils.tablex")

local equality = require("src.lua.matchers.equality")
local functions = require("src.lua.matchers.functions")
local mocks = require("src.lua.matchers.mocks")
local numbers = require("src.lua.matchers.numbers")
local strings = require("src.lua.matchers.strings")
local tables = require("src.lua.matchers.tables")

---@type table<string, lest.Matcher>
local matchers =
	tablex.merge(equality, functions, mocks, numbers, strings, tables)

return matchers
