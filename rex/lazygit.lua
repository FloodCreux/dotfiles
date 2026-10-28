require("utils")

rex.action({
	name = "lazygit",
	title = "Lazygit",
	run = FLOAT_COMMAND({ "lazygit" }, { bounds = { 0.05, 0.05, 0.9, 0.9 }, cwd = true }),
})

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>shift+g", "lazygit")
