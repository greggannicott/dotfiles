local wk = require("which-key")

wk.add({
	{ "<leader>t", group = "Testing" },
	{ "<leader>td", require("jasmine-toggle").toggle_describe, desc = "Toggle describe/fdescribe" },
})
