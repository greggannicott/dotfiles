-- Note: The require('go').setup() function is called in the config section of the plugin setup.
-- This file currently exists to set up key mappings for Go-related commands.
local wk = require("which-key")

wk.add({
	{ "<leader>cg", group = "Go" },
	{ "<leader>cga", ":GoAlt!<CR>", desc = "Toggle Between Alt Files" },
	{ "<leader>cgA", ":GoAltV!<CR>", desc = "Toggle Between Alt Files" },
	{ "<leader>cgd", ":GoDef<CR>", desc = "Go to Definition" },
	{ "<leader>cgr", ":GoRename<CR>", desc = "Rename" },
	{ "<leader>cgs", ":GoSignature<CR>", desc = "Signature Help" },
	{ "<leader>cgt", ":GoTestFunc<CR>", desc = "Test Function" },
	{ "<leader>cgT", ":GoTestFile<CR>", desc = "Test File" },
	{ "<leader>cgp", ":GoPkgBrowser<CR>", desc = "Package Browser" },
}, { mode = "n" })
