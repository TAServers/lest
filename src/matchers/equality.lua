local function toBe(received, expected)
	return {
		pass = received == expected,
		message = function(ctx)
			return string.format(
				"Expected %s to%sbe %s",
				tostring(received),
				ctx.inverted and " not " or " ",
				tostring(expected)
			)
		end,
	}
end

return {
	toBe = toBe,
}
