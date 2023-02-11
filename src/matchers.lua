local mergeTables = require("src.utils.mergeTables")

local equality = require("src.matchers.equality")

return mergeTables(equality)
