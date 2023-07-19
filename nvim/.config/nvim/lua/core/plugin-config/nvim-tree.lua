vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local wk = require('which-key')

-- Define key mappings to be used within the plugin
local function my_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
end


require('nvim-tree').setup({
  on_attach = my_on_attach
})

-- Mappings
wk.register({
  e = {
    name = 'Explorer',
    c = { ':NvimTreeCollapse<CR>', 'Collapse All Nodes' },
    e = { ':NvimTreeToggle<CR>', 'Toggle' },
    f = { ':NvimTreeFindFile<CR>', 'Focus Current File' },
    r = { ':NvimTreeResize 30<CR>', 'Reduce Window Size' },
    x = { ':NvimTreeResize 70<CR>', 'Expand Window Size' },
  }
}, { prefix = '<leader>'})
