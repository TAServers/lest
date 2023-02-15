local registerError = require("src.errors.register")

return registerError("TimeoutError", function()
	return {
		message = "Function call timed out",
	}
end)
