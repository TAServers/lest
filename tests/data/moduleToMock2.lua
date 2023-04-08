local function foo()
	error("Module was not mocked")
end

return { foo = foo }
