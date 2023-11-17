local wc = require("which-key")
-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
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

	nmap("gr", require("telescope.builtin").lsp_references, "Goto References")
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

	-- Lesser used LSP functionality
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

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
	-- clangd = {},
	-- gopls = {},
	-- pyright = {},
	-- rust_analyzer = {},
	-- tsserver = {},

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
}

-- Setup neovim lua configuration
require("neodev").setup()

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
