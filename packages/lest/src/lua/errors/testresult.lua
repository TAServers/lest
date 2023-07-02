local COLOURS = require("src.lua.utils.consoleColours")
local registerError = require("src.lua.errors.register")
return registerError("TestResultError", function(message, signature)
	return {
		message = message,
		signature = signature,
	}
end, {
	__tostring = function(self)
		return string.format(
			"%s\n\n%s",
			self.signature,
			COLOURS.FAIL(self.message)
		)
	end,
})
