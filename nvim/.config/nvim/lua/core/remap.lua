local wk = require("which-key")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = "unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"
-- Don't display diagnostic details in the signcolumn.
require("vim.diagnostic").config({
	signs = false,
})

-- Display dianostic messages in the virtual text (no longer the default in Neovim 0.11)
vim.diagnostic.config({ virtual_text = true })

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect,noinsert,preview"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Formatting.

-- Don't start new lines with comment symbols if current line has comment symbols
-- NOTE: This doesn't work for some reason.
vim.o.formatoptions = "cro"

-- Set tab width. Default appears to be 8!
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Set relative numbers
vim.wo.relativenumber = true

-- Display the cursor line
vim.wo.cursorline = true
vim.wo.cursorlineopt = "both"

-- Don't display status information under each window
vim.go.laststatus = 3

-- Display the name and state of each file in the top right
vim.go.winbar = "%=%m %t"

-- Open file to right when performing split
vim.go.splitright = true
vim.go.splitbelow = true

-- Always have the top/bottom N lines displayed in buffer
vim.o.scrolloff = 8

-- Determine how diffs are displayed
-- See: https://www.reddit.com/r/neovim/comments/1ihpvaf/the_linematch_diffopt_makes_builtin_diff_so_sweat/
vim.o.diffopt = "internal,filler,closeoff,linematch:60"

-- Tab related mappings
wk.add({
	{ "<leader>T", group = "Tabs" },
	{ "<leader>Tc", "<cmd>:tabclose<CR>", desc = "Close Tab" },
	{ "<leader>Th", "<cmd>:tabprevious<CR>", desc = "Previous Tab" },
	{ "<leader>Tl", "<cmd>:tabnext<CR>", desc = "Next Tab" },
	{ "<leader>Tn", "<cmd>:tabnew<CR>", desc = "New Tab" },
})
vim.keymap.set("n", "L", "<cmd>tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "H", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

-- Remap resizing of windows
vim.api.nvim_set_keymap("n", "<C-Right>", "<cmd>:vertical res +2<cr>", { desc = "Increase Window Width" })
vim.api.nvim_set_keymap("n", "<C-Left>", "<cmd>:vertical res -2<cr>", { desc = "Decrease Window Width" })
vim.api.nvim_set_keymap("n", "<C-up>", "<cmd>:res +2<cr>", { desc = "Increase Window Height" })
vim.api.nvim_set_keymap("n", "<C-down>", "<cmd>:res -2<cr>", { desc = "Decrease Window Height" })

-- Ability to move higlighted lines of code (via The Primeagen)
vim.api.nvim_set_keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted line down", silent = true })
vim.api.nvim_set_keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted line up", silent = true })

-- Quickfix List Mappings
vim.api.nvim_set_keymap("n", "[[", "<cmd>cprev<CR>", { desc = "Previous Quickfix" })
vim.api.nvim_set_keymap("n", "]]", "<cmd>cnext<CR>", { desc = "Next Quickfix" })

-- EXPERIMENT: Disable h/j/k/l movement in normal mode
--[[ vim.api.nvim_set_keymap("n", "h", "<Nop>", { silent = true })
vim.api.nvim_set_keymap("n", "j", "<Nop>", { silent = true })
vim.api.nvim_set_keymap("n", "k", "<Nop>", { silent = true })
vim.api.nvim_set_keymap("n", "l", "<Nop>", { silent = true }) ]]

-- Plugin Development mappings
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })

-- Use ripgrep in place of grep
vim.o.grepprg = "rg --vimgrep --no-heading --smart-case --follow --hidden"
vim.o.grepformat = "%f:%l:%c:%m"
