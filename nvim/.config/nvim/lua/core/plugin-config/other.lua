local wk = require("which-key")
require("other-nvim").setup({
	mappings = {
		-- builtin mappings
		"angular",
	},
	style = {
		-- How the plugin paints its window borders
		-- Allowed values are none, single, double, rounded, solid and shadow
		border = "solid",

		-- Column seperator for the window
		seperator = "|",

		-- width of the window in percent. e.g. 0.5 is 50%, 1.0 is 100%
		width = 0.7,

		-- min height in rows.
		-- when more columns are needed this value is extended automatically
		minHeight = 2,
	},
})

wk.add({
	{ "<leader>ca", group = "Angular" },
	{ "<leader>caC", "<cmd>:OtherVSplit component<cr>", desc = "Open Component (vertical split)" },
	{ "<leader>caH", "<cmd>:OtherVSplit html<cr>", desc = "Open HTML (vertical split)" },
	{ "<leader>caS", "<cmd>:OtherVSplit service<cr>", desc = "Open Service (vertical split)" },
	{ "<leader>caT", "<cmd>:OtherVSplit test<cr>", desc = "Open Test (vertical split)" },
	{ "<leader>caY", "<cmd>:OtherVSplit scss<cr>", desc = "Open SCSS (vertical split)" },
	{ "<leader>cac", "<cmd>:Other component<cr>", desc = "Open Component" },
	{ "<leader>cah", "<cmd>:Other html<cr>", desc = "Open HTML" },
	{ "<leader>cas", "<cmd>:Other service<cr>", desc = "Open Service" },
	{ "<leader>cat", "<cmd>:Other test<cr>", desc = "Open Test" },
	{ "<leader>cay", "<cmd>:Other scss<cr>", desc = "Open SCSS" },
})
