local equality = require("src.matchers.equality")

return table.pack(equality, { __index = equality })
