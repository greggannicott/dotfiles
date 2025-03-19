local wk = require("which-key")

wk.add({
	{ "<leader>t", group = "Testing" },
	{ "<leader>td", require("jasmine-toggle").toggle_describe_focus, desc = "Toggle describe/fdescribe" },
	{ "<leader>ti", require("jasmine-toggle").toggle_it_focus, desc = "Toggle it/fit" },
})
