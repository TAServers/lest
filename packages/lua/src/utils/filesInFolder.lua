local isUnix = require("src.utils.isUnix")
local getCwd = require("src.utils.cwd")

local WINDOWS_LIST_FILES = 'dir "%s" /a-D /S /B'
local BASH_LIST_FILES = 'find "%s" -type f'
local LIST_FILES_COMMAND = isUnix and BASH_LIST_FILES or WINDOWS_LIST_FILES

--- Returns a list of files at the specified path
---@param path? string -- File path to list. Defaults to the current directory
---@param normalise? boolean -- Normalise file separators to `/`. Defaults to true
---@return string[] -- List of files relative to the search path
return function(path, normalise)
	path = path or "."
	if normalise == nil then
		normalise = true
	end

	local handle, err = io.popen(string.format(LIST_FILES_COMMAND, path))
	local cwdLength = not isUnix and #getCwd() + 1

	if err then
		error(err)
	end

	if not handle then
		error("Process handle is nil")
	end

	local i, files = 0, {}
	for filepath in handle:lines() do
		i = i + 1
		files[i] = string.sub(filepath, isUnix and #path + 2 or cwdLength + 1)

		if normalise and not isUnix then
			files[i] = string.gsub(files[i], "\\", "/")
		end
	end

	handle:close()

	return files
end
