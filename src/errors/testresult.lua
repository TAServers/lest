local registerError = require("src.errors.register")
return registerError("TestResultError", function(message, signature)
	return {
		message = message,
		signature = signature,
	}
end)
