local harpoon = require("harpoon")
local wk = require("which-key")

harpoon:setup()

wk.add({
	{ "<leader>h", group = "Harpoon" },
	{
		"<leader>ha",
		function()
			harpoon:list():add()
		end,
		desc = "Add current file to Harpoon",
	},
	{
		"<leader>hh",
		function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end,
		desc = "Toggle Harpoon menu",
	},
	{
		"[f",
		function()
			harpoon:list():prev()
		end,
		desc = "Harpoon: Previous buffer",
	},
	{
		"]f",
		function()
			harpoon:list():next()
		end,
		desc = "Harpoon: Next buffer",
	},
	{
		"[[",
		function()
			harpoon:list():prev()
		end,
		desc = "Previous Harpoon buffer",
	},
	{
		"]]",
		function()
			harpoon:list():next()
		end,
		desc = "Next Harpoon buffer",
	},
})
