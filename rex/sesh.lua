rex.action({
	name = "sesh_picker",
	title = "Sesh Picker",
	run = function(ctx, args)
		rex.session.new_layer({
			bounds = { 0.1, 0.15, 0.8, 0.7 },
			focus = true,
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				options = { command = { "tv", "rex-sessions" } },
			}),
		})
	end,
})

rex.bind("ctrl+a>s", "sesh_picker")
