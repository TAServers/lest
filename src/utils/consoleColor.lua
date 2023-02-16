local ANSI_COLOR_TEMPLATE = "\x1b[%s;%s;%sm"
local DEFAULT_BG_CODE = 49

local RESET_CODE = ANSI_COLOR_TEMPLATE:format(0, 0, 0)

--- Creates a function which takes in text and colors it according to the arguments.
---@param modifier number 0 means normal, 1 means bold and 2 means dimmed
---@param colorCode number ANSI escape color code
---@param bgColorCode number|nil Optional background color code
---@return fun(text:string|nil):string textFn
local function createColoredTextFn(modifier, colorCode, bgColorCode)
	return function(text)
		text = text or ""
		bgColorCode = bgColorCode or DEFAULT_BG_CODE

		return ANSI_COLOR_TEMPLATE:format(
			tostring(modifier),
			tostring(colorCode),
			tostring(bgColorCode)
		) .. text .. RESET_CODE
	end
end

return {
	GREEN = createColoredTextFn(0, 32),
	RED = createColoredTextFn(0, 31),

	WHITE_ON_RED_BOLD = createColoredTextFn(1, 37, 41),
	WHITE_ON_GREEN_BOLD = createColoredTextFn(1, 37, 42),

	BOLD = createColoredTextFn(1, 39),
	BOLD_RED = createColoredTextFn(1, 31),

	DIMMED = createColoredTextFn(2, 39),
}
