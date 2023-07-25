local ls = require 'luasnip'
-- config

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI"
}

-- Shortcut to source your Snippets
vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/core/plugin-config/luasnip.lua<CR>")

-- Import Snippets
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/core/snippets"})
