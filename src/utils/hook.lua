lest = lest or {}
lest._realSetHook = lest._realSetHook or debug.sethook
local sethook = lest._realSetHook

---@diagnostic disable-next-line: duplicate-set-field
function debug.sethook()
	error("sethook is not currently supported inside the Lest runtime")
end

---@alias event
---| "call"
---| "tail call"
---| "return"
---| "line"
---| "count"

---@type table<event, fun(event: string, line?: integer) | nil>
local hooks = {}

local hookSet = false
local function lazyEnableHook()
	local hasHook = false
	for _, hook in pairs(hooks) do
		if hook then
			hasHook = true
		end
	end

	if hasHook and not hookSet then
		hookSet = true
		sethook(function(event, line)
			if hooks[event] then
				hooks[event](event, line)
			end
		end, "crl", 1)
	elseif not hasHook and hookSet then
		hookSet = false
		sethook()
	end
end

local hook = {}

--- Sets the hook function for call and tail call events
---@param func? fun(event: "call" | "tail call")
function hook.setCallHook(func)
	hooks.call = func
	hooks["tail call"] = func

	lazyEnableHook()
end

--- Sets the hook function for return events
---@param func? fun(event: "return")
function hook.setReturnHook(func)
	hooks["return"] = func

	lazyEnableHook()
end

--- Sets the hook function for line events
---@param func? fun(event: "line", line: integer)
function hook.setLineHook(func)
	hooks.line = func

	lazyEnableHook()
end

--- Sets the hook function for count events
---@param func? fun(event: "count")
function hook.setCountHook(func)
	hooks.count = func

	lazyEnableHook()
end

return hook
