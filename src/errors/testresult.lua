local COLOURS = require("src.utils.consoleColours")
local registerError = require("src.errors.register")
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
