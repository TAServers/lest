local function toBe(self, received)
	local expected = self.expected
	return expected == received,
		"Expected " .. tostring(expected) .. " to be " .. tostring(received)
end

return {
	toBe = toBe,
}
