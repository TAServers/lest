local ANSI_COLOUR_TEMPLATE = "\x1b[%s;%s;%sm%s\x1b[0;0;0m"
local DEFAULT_BG_CODE = 49

--- Creates a function which takes in text and colours it according to the arguments.
---@param modifier number 0 means normal, 1 means bold and 2 means dimmed
---@param colourCode number ANSI escape colour code
---@param bgColourCode number|nil Optional background colour code
---@return fun(text:string):string textFn
local function createColouredTextFn(modifier, colourCode, bgColourCode)
	return function(text)
		bgColourCode = bgColourCode or DEFAULT_BG_CODE

		return ANSI_COLOUR_TEMPLATE:format(
			tostring(modifier),
			tostring(colourCode),
			tostring(bgColourCode),
			text
		)
	end
end

local COLORS = {
	PASS = createColouredTextFn(0, 32),
	FAIL = createColouredTextFn(0, 31),

	PASS_HEADER = createColouredTextFn(1, 37, 42),
	FAIL_HEADER = createColouredTextFn(1, 37, 41),

	TESTS_PASSED = createColouredTextFn(1, 32),
	TESTS_FAILED = createColouredTextFn(1, 31),

	BOLD = createColouredTextFn(1, 39),
	DIMMED = createColouredTextFn(2, 39),
	HIGHLIGHT = createColouredTextFn(0, 37),
}

-- Aliases which may be changed or themed at a future date
COLORS.EXPECTED = COLORS.PASS
COLORS.RECEIVED = COLORS.FAIL
COLORS.FILENAME = COLORS.BOLD
COLORS.ERROR_HEADER = COLORS.TESTS_FAILED

return COLORS
