-- CONFIG
rex.bind("cmd+shift+r", "client.config.reload")

-- PREFIX: press ctrl-a twice to send one ctrl+a to the shell (beginning of the line)
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- PANE
rex.bind("ctrl+a>h", "pane.focus.left")
rex.bind("ctrl+a>j", "pane.focus.down")
rex.bind("ctrl+a>k", "pane.focus.up")
rex.bind("ctrl+a>l", "pane.focus.right")
rex.bind("ctrl+a>x", "pane.close")

rex.bind("ctrl+a>z", "pane.zoom")

-- TAB
rex.bind("ctrl+a>shift+h", "client.tab.previous")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>shift+l", "client.tab.next")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>r", "client.tab.rename")

for i = 1, 9, 1 do
	rex.bind(string.format("ctrl+a>%s", i), "client.tab.goto", { index = i })
end

-- SESSION
rex.bind("ctrl+a>shift+p", "session.previous")
rex.bind("ctrl+a>shift+4", "session.rename")
