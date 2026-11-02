require("utils")

rex.action({
	name = "help",
	title = "Help",
	run = FLOAT_COMMAND({ "tv", "rex-keys" }, { bounds = { 0.1, 0.1, 0.8, 0.8 } }),
})

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>shift+/", "help")
