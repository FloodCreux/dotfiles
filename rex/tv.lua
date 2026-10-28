require("utils")

rex.action({
	name = "sesh_picker",
	title = "Sesh Picker",
	run = FLOAT_COMMAND({ "tv", "rex-sessions" }, { bounds = { 0.1, 0.15, 0.8, 0.7 } }),
})

rex.action({
	name = "tv",
	title = "TV",
	run = FLOAT_COMMAND({ "tv" }, { bounds = { 0.05, 0.05, 0.9, 0.9 }, cwd = true }),
})

rex.action({
	name = "tv_text",
	title = "TV Text",
	run = FLOAT_COMMAND({ "tv", "text" }, { bounds = { 0.05, 0.05, 0.9, 0.9 }, cwd = true }),
})

rex.action({
	name = "new_session",
	title = "New Session",
	run = FLOAT_COMMAND({ "tv", "rex-new-session" }, { bounds = { 0.1, 0.15, 0.8, 0.7 } }),
})

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>s", "sesh_picker")

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>t", "tv")

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>x", "tv_text")

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>shift+t", "new_session")
