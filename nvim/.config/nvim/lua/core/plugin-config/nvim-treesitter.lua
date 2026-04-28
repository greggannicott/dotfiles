--
-- Install required parsers
--
local ensureinstalled = {
	"go",
	"lua",
	"tsx",
	"typescript",
	"vimdoc",
	"vim",
	"html",
	"json",
	"jsdoc",
	"markdown",
	"scss",
	"yaml",
	"gitcommit",
	"diff",
	"git_rebase",
	"tmux",
	"angular",
}

local alreadyinstalled = require("nvim-treesitter.config").get_installed()
local parserstoinstall = vim.iter(ensureinstalled)
	:filter(function(parser)
		return not vim.tbl_contains(alreadyinstalled, parser)
	end)
	:totable()
require("nvim-treesitter").install(parserstoinstall)

--
-- Enable treesitter highlighting when files open
--
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- Enable treesitter highlighting and disable regex syntax
		pcall(vim.treesitter.start)
		-- Enable treesitter-based indentation
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

--
-- Configure treesitter-text-objects
--
require("nvim-treesitter-textobjects").setup({
	move = {
		-- whether to set jumps in the jumplist
		set_jumps = true,
	},
})

--
-- Add custom mappings for interacting with arguments
--
vim.keymap.set({ "n", "x", "o" }, "]a", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]A", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[a", function()
	require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[A", function()
	require("nvim-treesitter-textobjects.move").goto_previos_start("@parameter.inner", "textobjects")
end)
