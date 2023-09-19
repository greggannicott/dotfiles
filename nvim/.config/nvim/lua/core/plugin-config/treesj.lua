require("treesj").setup()
local wk = require("which-key")

wk.register({
	c = {
		t = { "<cmd>TSJToggle<cr>", "Toggle fuction/array/object" },
	},
}, { prefix = "<leader>" })
