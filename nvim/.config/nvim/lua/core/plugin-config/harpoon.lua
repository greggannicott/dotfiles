local wk = require("which-key")

wk.register({
	h = {
		name = "Harpoon",
		a = { require("harpoon.mark").add_file, "Add File" },
		h = { require("harpoon.ui").toggle_quick_menu, "Display Marks" },
	},
}, { prefix = "<leader>" })
