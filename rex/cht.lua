require("utils")

rex.action({
	name = "cht",
	title = "Cheat Sheet",
	run = FLOAT_COMMAND({ os.getenv("HOME") .. "/.config/tmux/scripts/tmux-cht" }),
})

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>i", "cht")
