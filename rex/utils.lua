local terminal = "com.superlogical.terminal"
local terminal_shell = "com.superlogical.terminal.shell"

local DEFAULT_BOUNDS = { 0.1, 0.1, 0.8, 0.8 }

function CURRENT_CWD()
	local proc = rex.block.call(terminal, "process", {})
	if proc and proc.foreground and proc.foreground.cwd then
		return proc.foreground.cwd
	end

	if proc and proc.child and proc.child.cwd then
		return proc.child.cwd
	end

	return os.getenv("HOME")
end

---@param command string[]
---@param opts? { bounds?: number[], cwd?: boolean }
function FLOAT_COMMAND(command, opts)
	opts = opts or {}

	return function(ctx, args)
		local options = { command = command }
		if opts.cwd then
			options.cwd = CURRENT_CWD()
		end

		rex.session.new_layer({
			bounds = opts.bounds or DEFAULT_BOUNDS,
			focus = true,
			layout = rex.layout.block({
				flavor = terminal_shell,
				options = options,
			}),
		})
	end
end
