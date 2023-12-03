local ConfigLoader = require("src.lua.utils.configLoader")

return ConfigLoader.new()
	:registerProperty("testTimeout", {
		type = "number",
		default = 5000,
	})
	:registerProperty("testMatch", {
		type = "table",
		default = { ".+%.test%.lua" },
	})
	:load(arg)
