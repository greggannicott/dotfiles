local wk = require("which-key")

---------------
-- SETUP LSP --
---------------

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
	-- Prevent "ts_ls" from formatting code. This is to prevent it from clashing with Prettier.
	if client.name == "ts_ls" then
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

	nmap("gI", function()
		require("telescope.builtin").lsp_implementations({ fname_width = 85 })
	end, "Goto Implementation")
	nmap("<leader>cI", require("telescope.builtin").lsp_implementations, "Search Implementations")

	nmap("<leader>cD", vim.lsp.buf.type_definition, "Goto Type Definition")

	nmap("<C-t>", function()
		require("telescope.builtin").lsp_document_symbols({
			symbol_width = 70,
		})
	end, "Search Document Symbols")
	nmap("<leader>cy", function()
		require("telescope.builtin").lsp_document_symbols({
			symbol_width = 70,
		})
	end, "Search Document Symbols")
	-- We're using `lsp_dynamic_workspace_symbols` instead of `lsp_workspace_symbols` as it works with golang.
	-- The drawback is that you're now unable to specify symbol type using `:type:` in the prompt.
	nmap("<C-y>", function()
		require("telescope.builtin").lsp_dynamic_workspace_symbols({
			symbol_width = 45,
		})
	end, "Search Dynamic Workspace Symbols")
	nmap("<leader>cY", function()
		require("telescope.builtin").lsp_dynamic_workspace_symbols({
			symbol_width = 45,
		})
	end, "Search Dynamic Workspace Symbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<leader>cK", vim.lsp.buf.hover, "Hover Documentation")
	-- Commented out as it was clashing with something else. Remap it when you get around
	-- to having a standard set of mappings for LSP stuff.
	-- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	nmap("<leader>ce", vim.diagnostic.open_float, "View Error Details")
	nmap("<leader>c[", vim.diagnostic.goto_prev, "Go to previous error")
	nmap("<leader>c]", vim.diagnostic.goto_next, "Go to next error")

	-- Give the '<leader>c' the name 'Code' in which-key.
	wk.add({
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
	["angularls@17.3.2"] = {},
	ts_ls = {},
	html = {},
	cssls = {},
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
	gopls = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
			gofumpt = true,
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
		local server_config = {
			capabilities = capabilities,
			on_attach = on_attach,
		}
		-- Add settings if they exist for this server
		if servers[server_name] then
			server_config.settings = servers[server_name]
		end

		vim.lsp.config(server_name, server_config)
		vim.lsp.enable(server_name)
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
-- SETUP TS ERRORS     --
-------------------------

require("ts-error-translator").setup()
