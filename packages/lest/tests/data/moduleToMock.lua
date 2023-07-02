local function foo()
	error("Module was not mocked")
end

local function bar()
	error("Module was not mocked")
end

return { funcs = { foo = foo, bar = bar } }, foo, bar
