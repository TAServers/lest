local tablex = require("src.utils.tablex")

local equality = require("src.matchers.equality")
local mocks = require("src.matchers.mocks")

---@type table<string, lest.Matcher>
local matchers = tablex.merge(equality, mocks)

return matchers
