local harpoon = require("harpoon")
local wk = require("which-key")

harpoon:setup()

wk.register({
	["<leader>h"] = {
		name = "Harpoon",
		a = {
			function()
				harpoon:list():add()
			end,
			"Add current file to Harpoon",
		},
		h = {
			function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			"Toggle Harpoon menu",
		},
	},
	["[f"] = {
		function()
			harpoon:list():prev()
		end,
		"Harpoon: Previous buffer",
	},
	["]f"] = {
		function()
			harpoon:list():next()
		end,
		"Harpoon: Next buffer",
	},
}, {})
