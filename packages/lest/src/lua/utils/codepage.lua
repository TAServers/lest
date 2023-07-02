local isUnix = require("src.lua.utils.isUnix")

local originalCodepage

if not isUnix then
	local handle = io.popen("chcp")
	if not handle then
		return
	end

	local result = handle:read()
	local _, _, codepage = string.find(result, "Active code page: (%d+)")
	originalCodepage = tonumber(codepage)

	handle:close()
end

local function setCodepage(codepage)
	if not originalCodepage then
		return
	end

	local handle = io.popen(string.format("chcp %i", codepage))
	if not handle then
		error("Failed to set codepage")
	end

	handle:close()
end

local function restoreCodepage()
	setCodepage(originalCodepage)
end

return {
	set = isUnix and function() end or setCodepage,
	restore = isUnix and function() end or restoreCodepage,
}
