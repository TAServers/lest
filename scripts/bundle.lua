local success =
	os.execute([[luabundler bundle lest.lua -p "./?.lua" -o dist/lest.lua]])
os.exit(success and 0 or 1)
