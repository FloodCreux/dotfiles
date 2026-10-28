require("utils")

rex.action({
	name = "yazi",
	title = "Yazi",
	run = FLOAT_COMMAND({ "yazi" }, { bounds = { 0.05, 0.05, 0.9, 0.9 }, cwd = true }),
})

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>e", "yazi")
