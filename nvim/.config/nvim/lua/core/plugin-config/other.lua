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
	{ "<leader>a", group = "Angular" },
	{ "<leader>aC", "<cmd>:OtherVSplit component<cr>", desc = "Open Component (vertical split)" },
	{ "<leader>aH", "<cmd>:OtherVSplit html<cr>", desc = "Open HTML (vertical split)" },
	{ "<leader>aS", "<cmd>:OtherVSplit service<cr>", desc = "Open Service (vertical split)" },
	{ "<leader>aT", "<cmd>:OtherVSplit test<cr>", desc = "Open Test (vertical split)" },
	{ "<leader>aY", "<cmd>:OtherVSplit scss<cr>", desc = "Open SCSS (vertical split)" },
	{ "<leader>ac", "<cmd>:Other component<cr>", desc = "Open Component" },
	{ "<leader>ah", "<cmd>:Other html<cr>", desc = "Open HTML" },
	{ "<leader>as", "<cmd>:Other service<cr>", desc = "Open Service" },
	{ "<leader>at", "<cmd>:Other test<cr>", desc = "Open Test" },
	{ "<leader>ay", "<cmd>:Other scss<cr>", desc = "Open SCSS" },
})
