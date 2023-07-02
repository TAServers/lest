local isUnix = require("src.lua.utils.isUnix")

local WINDOWS_CWD = "cd"
local BASH_CWD = "pwd"
local CWD_COMMAND = isUnix and BASH_CWD or WINDOWS_CWD

return function()
	local handle, err = io.popen(CWD_COMMAND)

	if err then
		error(err)
	end

	if not handle then
		error("Process handle is nil")
	end

	local cwd = handle:read()
	handle:close()

	return cwd
end
