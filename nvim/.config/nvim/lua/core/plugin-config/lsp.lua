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
	nmap("<leader>cA", vim.lsp.buf.code_action, "Code Actions")

	nmap("gd", vim.lsp.buf.definition, "Goto Definition")
	nmap("<leader>cd", vim.lsp.buf.definition, "Goto Definition")

	nmap("gr", function()
		require("telescope.builtin").lsp_references({
			layout_config = {
				prompt_position = "top",
				width = 200,
			},
			sorting_strategy = "ascending",
		})
	end, "Search References")
	nmap("<leader>cR", require("telescope.builtin").lsp_references, "Search References")

	nmap("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
	nmap("<leader>cI", require("telescope.builtin").lsp_implementations, "Search Implementations")

	nmap("<leader>cD", vim.lsp.buf.type_definition, "Goto Type Definition")

	nmap("<leader>cy", require("telescope.builtin").lsp_document_symbols, "Search Document Symbols")
	nmap("<C-t>", require("telescope.builtin").lsp_document_symbols, "Search Document Symbols")
	nmap("<leader>cY", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Search Workspace Symbols")
	nmap("<C-y>", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Search Workspace Symbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<leader>cK", vim.lsp.buf.hover, "Hover Documentation")
	-- Commented out as it was clashing with something else. Remap it when you get around
	-- to having a standard set of mappings for LSP stuff.
	-- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	nmap("<leader>ce", vim.diagnostic.open_float, "View Error Details")
	nmap("<leader>c[", vim.diagnostic.goto_prev, "Go to previous error")
	nmap("[e", vim.diagnostic.goto_prev, "Go to previous error")
	nmap("<leader>c]", vim.diagnostic.goto_next, "Go to next error")
	nmap("]e", vim.diagnostic.goto_next, "Go to next error")

	-- Give the '<leader>c' the name 'Code' in which-key.
	wc.add({
		{ "<leader>c", group = "Code" },
	})
end

-- Style the diagnostic message
vim.diagnostic.config({
	float = {
		border = "rounded",
	},
})

-- Setup neovim lua configuration
require("neodev").setup()

-- Enable the following language servers
local servers = {
	["angularls@16.2.0"] = {},
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

-------------------------
-- SETUP TS ERRORS     --
-------------------------

require("ts-error-translator").setup()
