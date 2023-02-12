local tablex = require("src.utils.tablex")

local equality = require("src.matchers.equality")
local mocks = require("src.matchers.mocks")

return tablex.merge(equality, mocks)
