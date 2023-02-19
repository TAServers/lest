local isUnix = require("src.utils.isUnix")
local colours = require("src.utils.consoleColor")

local originalCodepage

do
	local handle = io.popen("chcp")
	if not handle then
		return
	end

	local result = handle:read("l")
	local _, _, codepage = string.find(result, "Active code page: (%d+)")
	originalCodepage = tonumber(codepage)

	handle:close()
end

local function setCodepage(codepage)
	if not originalCodepage then
		return
	end

	local success = os.execute(string.format("chcp %i", codepage))
	if not success then
		error("Failed to set codepage")
	end
end

local function restoreCodepage()
	setCodepage(originalCodepage)
end

return {
	set = isUnix and function() end or setCodepage,
	restore = isUnix and function() end or restoreCodepage,
}
