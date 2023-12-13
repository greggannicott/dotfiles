-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require("lazy").setup({
	"tpope/vim-fugitive",
	"nvim-tree/nvim-tree.lua",
	{ "nvim-telescope/telescope.nvim",       branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
	-- Fuzzy Finder Algorithm which requires local dependencies to be built.
	-- Only load if `make` is available. Make sure you have the system
	-- requirements installed.
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		-- NOTE: If you are having trouble with this installation,
		--       refer to the README for telescope-fzf-native for more instructions.
		build = "make",
		cond = function()
			return vim.fn.executable("make") == 1
		end,
	},
	"nvim-tree/nvim-web-devicons",
	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
	},
	{
		-- Theme inspired by Atom
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("onedark")
		end,
	},
	"nvim-lualine/lualine.nvim",
	-- Add indentation guides even on blank lines
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl",     opts = {} },
	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim",       tag = "legacy", opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			"folke/neodev.nvim",
		},
	},
	-- Install prettier and null-ls for prettier support
	"jose-elias-alvarez/null-ls.nvim",
	"MunifTanjim/prettier.nvim",
	-- Autocompletion & Snippets
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",

			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",

			-- Buffer completion
			"hrsh7th/cmp-buffer",

			-- Adds a number of user-friendly snippets
			"rafamadriz/friendly-snippets",
		},
	},
	-- Useful plugin to show you pending keybinds.
	{ "folke/which-key.nvim",  opts = {} },
	-- "gc" to comment visual regions/lines
	{ "numToStr/Comment.nvim", opts = {} },
	-- Adds git releated signs to the gutter, as well as utilities for managing changes
	"lewis6991/gitsigns.nvim",
	"tpope/vim-sleuth",
	"sindrets/diffview.nvim",
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {}, -- this is equalent to setup({}) function
	},
	"rgroli/other.nvim",
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
	},
	"chentoast/marks.nvim",
	"rcarriga/nvim-notify",
	-- Ability to search various dev docs
	{
		"luckasRanarison/nvim-devdocs",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-treesitter/nvim-treesitter",
			"debugloop/telescope-undo.nvim",
		},
	},
	-- Have your vim keybindings work with tmux when navigating windows
	"christoomey/vim-tmux-navigator",
	-- Ability to bookmark certain files within a project:
	"ThePrimeagen/harpoon",
	-- Highlight lines used when specifying ranges:
	"winston0410/cmd-parser.nvim",
	"winston0410/range-highlight.nvim",
	"Wansmer/treesj",
	"github/copilot.vim",
	"mfussenegger/nvim-dap",
	"leoluz/nvim-dap-go",
	"DNLHC/glance.nvim",
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{ "nvim-pack/nvim-spectre",         dev = true },
	-- Your own plugin:
	{ "greggannicott/angular-cli.nvim", dev = true },
}, {
	dev = {
		path = "~/code",
	},
})
