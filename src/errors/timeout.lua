local registerError = require("src.errors.register")

return registerError("TimeoutError", function(timeout)
	return {
		message = string.format(
			"Function call exceeded %ims timeout",
			timeout * 1000
		),
	}
end)
