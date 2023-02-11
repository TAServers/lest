local function toBe(received, expected, ctx)
	if ctx.inverted then
		return {
			pass = received ~= expected,
			message = string.format(
				"Expected %s to not be %s",
				tostring(received),
				tostring(expected)
			),
		}
	end

	return {
		pass = received == expected,
		message = string.format(
			"Expected %s to be %s",
			tostring(received),
			tostring(expected)
		),
	}
end

return {
	toBe = toBe,
}
