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
vim.o.formatoptions = cro

-- Set tab width. Default appears to be 8!
vim.o.tabstop = 4

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

-- Tab related mappings
wk.register({
	T = {
		name = "Tabs",
		c = { "<cmd>:tabclose<CR>", "Close Tab" },
		h = { "<cmd>:tabprevious<CR>", "Previous Tab" },
		l = { "<cmd>:tabnext<CR>", "Next Tab" },
		n = { "<cmd>:tabnew<CR>", "New Tab" },
	},
}, { prefix = "<leader>" })
vim.keymap.set("n", "L", "<cmd>tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "H", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })

-- Remap navigation of windows so you can just use ctrl + h/j/k/l
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true })

-- Remap resizing of windows
vim.api.nvim_set_keymap("n", "<C-Right>", "<cmd>:vertical res +1<cr>", { desc = "Increase Window Width" })
vim.api.nvim_set_keymap("n", "<C-Left>", "<cmd>:vertical res -1<cr>", { desc = "Decrease Window Width" })
vim.api.nvim_set_keymap("n", "<C-up>", "<cmd>:res +1<cr>", { desc = "Increase Window Height" })
vim.api.nvim_set_keymap("n", "<C-down>", "<cmd>:res -1<cr>", { desc = "Decrease Window Height" })

-- Mapping for opening config file
vim.keymap.set("n", "<leader>.", ":vs ~/.config/nvim/init.lua<CR>", { desc = "Open Neovim Config" })

-- Plugin Development mappings
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })
