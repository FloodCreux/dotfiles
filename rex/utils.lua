local terminal = "com.superlogical.terminal"

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
