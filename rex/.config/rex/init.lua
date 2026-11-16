-- Key sequences, following tmux conventions.

-- Zoom the focused pane. Pressing the sequence again restores the layout.
rex.bind("ctrl+b>z", "pane.zoom")

-- Split the focused pane right (|) or down (-).
rex.bind("ctrl+b>shift+[Backslash]", "pane.split", { direction = "right" })
rex.bind("ctrl+b>-", "pane.split", { direction = "down" })

-- Close the focused pane.
rex.bind("ctrl+b>x", "pane.close")
