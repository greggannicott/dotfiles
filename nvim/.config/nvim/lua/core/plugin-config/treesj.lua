require("treesj").setup()
local wk = require("which-key")

wk.add({
	{ "<leader>c<C-t>", "<cmd>TSJToggle<cr>", desc = "Toggle function/array/object" },
})
