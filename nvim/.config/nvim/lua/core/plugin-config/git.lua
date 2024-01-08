local wk = require("which-key")

local function showFugitiveGit()
	if vim.fn.FugitiveHead() ~= "" then
		vim.cmd([[
    Git
    " wincmd H  " Open Git window in vertical split
    " setlocal winfixwidth
    " vertical resize 31
    " setlocal winfixwidth
    setlocal nonumber
    setlocal norelativenumber
    ]])
	end
end
local function toggleFugitiveGit()
	if
		(vim.fn.buflisted(vim.fn.bufname("fugitive:///*/.git//$")) ~= 0)
		or vim.fn.buflisted(vim.fn.bufname("fugitive:///*/.bare/*")) ~= 0
	then
		vim.cmd([[ execute ":bdelete" bufname('fugitive:///*/.git//$') ]])
	else
		showFugitiveGit()
	end
end

require("gitsigns").setup({

	-- See `:help gitsigns.txt`
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	on_attach = function(bufnr)
		-- Note: the 'which' description for these mappings are handled below as you were
		-- unable to get which-key.register to work within the on_attach.
		vim.keymap.set("n", "<leader>ghp", require("gitsigns").prev_hunk, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ghn", require("gitsigns").next_hunk, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ghv", require("gitsigns").preview_hunk, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ghs", require("gitsigns").stage_hunk, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ghr", require("gitsigns").reset_hunk, { buffer = bufnr })
	end,
})

wk.register({
	["["] = {
		h = { require("gitsigns").prev_hunk, "Previous hunk" },
	},
	["]"] = {
		h = { require("gitsigns").next_hunk, "Next hunk" },
	},
	["<leader>"] = {
		g = {
			name = "Git",
			b = {
				name = "Blame",
				b = { ":Git blame<CR>", "Display blame column" },
				d = { ":Gitsigns blame_line<CR>", "Display blame detail for current line" },
				l = { ":Gitsigns toggle_current_line_blame<CR>", "Toggle line blame" },
			},
			g = { toggleFugitiveGit, "Git Status" },
			c = {
				name = "Commit",
				c = { ":Git commit<CR>", "Git Commit" },
				a = { ":Git commit --amend<CR>", "Git Commit Amend" },
			},
			h = {
				name = "Hunk",
				p = "Previous Hunk",
				n = "Next Hunk",
				v = "View Hunk",
				s = "Stage Hunk",
				r = "Reset Hunk",
			},
			d = {
				name = "Diff",
				b = { ":DiffviewOpen origin/main... --imply-local<CR>", "Diff branch with main" },
				d = { "<CMD>DiffviewOpen<CR>", "View diff of altered files" },
				o = { "<CMD>DiffviewOpen @{u}<CR>", "Diff branch with remote" },
			},
		},
	},
}, {})
