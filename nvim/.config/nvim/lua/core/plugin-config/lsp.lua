local wc = require("which-key")

---------------
-- SETUP LSP --
---------------

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
	-- Prevent "tsserver" from formatting code. This is to prevent it from clashing with Prettier.
	if client.name == "tsserver" then
		client.server_capabilities.documentFormattingProvider = false
	end

	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>cr", vim.lsp.buf.rename, "Rename")
	nmap("<leader>c<C-a>", vim.lsp.buf.code_action, "Code Actions")

	nmap("gd", vim.lsp.buf.definition, "Goto Definition")
	nmap("<leader>cd", vim.lsp.buf.definition, "Goto Definition")

	nmap("gr", "<CMD>Glance references<CR>", "Goto References")
	nmap("<leader>cR", require("telescope.builtin").lsp_references, "Search References")

	nmap("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
	nmap("<leader>cI", require("telescope.builtin").lsp_implementations, "Search Implementations")

	nmap("<leader>cD", vim.lsp.buf.type_definition, "Goto Type Definition")

	nmap("<leader>cy", require("telescope.builtin").lsp_document_symbols, "Search Document Symbols")
	nmap("<leader>cY", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Search Workspace Symbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<leader>cK", vim.lsp.buf.hover, "Hover Documentation")
	-- Commented out as it was clashing with something else. Remap it when you get around
	-- to having a standard set of mappings for LSP stuff.
	-- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	nmap("<leader>ce", vim.lsp.buf.declaration, "Goto Declaration")
	nmap("<leader>c[", vim.diagnostic.goto_prev, "Go to previous error")
	nmap("[e", vim.diagnostic.goto_prev, "Go to previous error")
	nmap("<leader>c]", vim.diagnostic.goto_next, "Go to next error")
	nmap("]e", vim.diagnostic.goto_next, "Go to next error")

	-- Give the '<leader>c' the name 'Code' in which-key.
	wc.register({
		c = {
			name = "Code",
		},
	}, { prefix = "<leader>" })
end

-- Setup neovim lua configuration
require("neodev").setup()

-- Enable the following language servers
local servers = {
	["angularls@15.2.1"] = {},
	tsserver = {},
	html = {},
	cssls = {},
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
	gopls = {
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
				gofumpt = true,
			},
		},
	},
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
		})
	end,
})

-------------------
-- SETUP NULL-LS --
-------------------

local null_ls = require("null-ls")

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

null_ls.setup({
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.keymap.set("n", "<Leader>f", function()
				vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
			end, { buffer = bufnr, desc = "[lsp] format" })

			-- format on save
			vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
			vim.api.nvim_create_autocmd(event, {
				buffer = bufnr,
				group = group,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr, async = async })
				end,
				desc = "[lsp] format on save",
			})
		end

		if client.supports_method("textDocument/rangeFormatting") then
			vim.keymap.set("x", "<Leader>f", function()
				vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
			end, { buffer = bufnr, desc = "[lsp] format" })
		end
	end,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettierd,
		null_ls.builtins.formatting.beautysh,
		null_ls.builtins.formatting.fixjson,
	},
})

-------------------------
-- SETUP GO FORMATTING --
-------------------------

-- I don't think this uses null-ls

-- Golang formatting with gopls
-- Based on: https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
vim.api.nvim_create_autocmd(event, {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = { only = { "source.organizeImports" } }
		-- buf_request_sync defaults to a 1000ms timeout. Depending on your
		-- machine and codebase, you may want longer. Add an additional
		-- argument after params if you find that you have to write the file
		-- twice for changes to be saved.
		-- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				end
			end
		end
		vim.lsp.buf.format({ async = false })
	end,
})

------------------
-- SETUP GLANCE --
------------------

local actions = require("glance").actions
require("glance").setup({
	height = 18, -- Height of the window
	zindex = 45,

	-- Or use a function to enable `detached` only when the active window is too small
	-- (default behavior)
	detached = function(winid)
		return vim.api.nvim_win_get_width(winid) < 100
	end,

	preview_win_opts = { -- Configure preview window options
		cursorline = true,
		number = true,
		wrap = true,
	},
	border = {
		enable = false, -- Show window borders. Only horizontal borders allowed
		top_char = "―",
		bottom_char = "―",
	},
	list = {
		position = "right", -- Position of the list window 'left'|'right'
		width = 0.33, -- 33% width relative to the active window, min 0.1, max 0.5
	},
	theme = { -- This feature might not work properly in nvim-0.7.2
		enable = true, -- Will generate colors for the plugin based on your current colorscheme
		mode = "auto", -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
	},
	mappings = {
		list = {
			["j"] = actions.next, -- Bring the cursor to the next item in the list
			["k"] = actions.previous, -- Bring the cursor to the previous item in the list
			["<Down>"] = actions.next,
			["<Up>"] = actions.previous,
			["<Tab>"] = actions.next_location, -- Bring the cursor to the next location skipping groups in the list
			["<S-Tab>"] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
			["<C-u>"] = actions.preview_scroll_win(5),
			["<C-d>"] = actions.preview_scroll_win(-5),
			["v"] = actions.jump_vsplit,
			["s"] = actions.jump_split,
			["t"] = actions.jump_tab,
			["<CR>"] = actions.jump,
			["o"] = actions.jump,
			["l"] = actions.open_fold,
			["h"] = actions.close_fold,
			["<leader>l"] = actions.enter_win("preview"), -- Focus preview window
			["q"] = actions.close,
			["Q"] = actions.close,
			["<Esc>"] = actions.close,
			["<C-q>"] = actions.quickfix,
			-- ['<Esc>'] = false -- disable a mapping
		},
		preview = {
			["Q"] = actions.close,
			["<Tab>"] = actions.next_location,
			["<S-Tab>"] = actions.previous_location,
			["<leader>l"] = actions.enter_win("list"), -- Focus list window
		},
	},
	hooks = {},
	folds = {
		fold_closed = "",
		fold_open = "",
		folded = true, -- Automatically fold list on startup
	},
	indent_lines = {
		enable = true,
		icon = "│",
	},
	winbar = {
		enable = true, -- Available strating from nvim-0.8+
	},
})
