return {
	push = function(tbl, value)
		tbl[#tbl + 1] = value
	end,
	pop = function(tbl)
		return table.remove(tbl, #tbl)
	end,
}
