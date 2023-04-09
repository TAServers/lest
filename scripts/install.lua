-- Fork of luamin used as upstream doesn't work in CI due to depending on a valid TTY
local success = os.execute(
	[[npm install -g luabundler https://github.com/hsandt/luamin.git#develop]]
)
os.exit(success and 0 or 1)
