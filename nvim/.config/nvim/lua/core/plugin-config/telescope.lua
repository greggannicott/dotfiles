local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")
telescope.setup {
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(telescope.load_extension, 'fzf')

-- Define keymappings to display presets
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch existing [B]uffers' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch git [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').lsp_references, { desc = '[S]earch [R]eferences' })
vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find,
  { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<C-p>', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').git_files(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
    prompt_title = "Find files...",
    layout_config = {
      width = 200
    }
  })
end, { desc = '[p] Find files' })

