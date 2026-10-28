require("utils")

rex.action({
	name = "lazygit",
	title = "Lazygit",
	---@diagnostic disable-next-line: unused-local
	run = function(ctx, args)
		rex.session.new_layer({
			bounds = { 0.1, 0.15, 0.8, 0.8 },
			focus = true,
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = {
					cwd = CURRENT_CWD(),
					command = { "lazygit" },
				},
			}),
		})
	end,
})

---@diagnostic disable-next-line: param-type-mismatch
rex.bind("ctrl+a>shift+g", "lazygit")
