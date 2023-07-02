-- Note, this cannot be replaced by an NPM script as luamin doesn't like redirecting output to a file

local BUNDLE_PATH = "dist/lua/lest.lua"

--- Throws the message if it is not nil
---@param message any
local function throwIfNotNil(message)
	if message ~= nil then
		error(message)
	end
end

local handle, popenError = io.popen("luamin -f " .. BUNDLE_PATH)
throwIfNotNil(popenError)

if not handle then
	error("Popen handle is nil")
end

local minified = handle:read("a")
handle:close()

if string.match(minified, "Error:") then
	error(minified)
end

local file, fileError = io.open(BUNDLE_PATH, "w+")
throwIfNotNil(fileError)

if not file then
	error("File handle is nil")
end

local _, writeError = file:write(minified)
throwIfNotNil(writeError)

file:close()
