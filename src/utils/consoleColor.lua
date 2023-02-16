local ANSI_COLOUR_TEMPLATE = "\x1b[%s;%s;%sm%s\x1b[0;0;0m"
local DEFAULT_BG_CODE = 49

--- Creates a function which takes in text and colours it according to the arguments.
---@param modifier number 0 means normal, 1 means bold and 2 means dimmed
---@param colourCode number ANSI escape colour code
---@param bgColourCode number|nil Optional background colour code
---@return fun(text:string|nil):string textFn
local function createColouredTextFn(modifier, colourCode, bgColourCode)
	return function(text)
		text = text or ""
		bgColourCode = bgColourCode or DEFAULT_BG_CODE

		return ANSI_COLOUR_TEMPLATE:format(
			tostring(modifier),
			tostring(colourCode),
			tostring(bgColourCode),
			text
		)
	end
end

return {
	GREEN = createColouredTextFn(0, 32),
	RED = createColouredTextFn(0, 31),

	WHITE_ON_RED_BOLD = createColouredTextFn(1, 37, 41),
	WHITE_ON_GREEN_BOLD = createColouredTextFn(1, 37, 42),

	BOLD = createColouredTextFn(1, 39),
	BOLD_RED = createColouredTextFn(1, 31),

	DIMMED = createColouredTextFn(2, 39),
}
