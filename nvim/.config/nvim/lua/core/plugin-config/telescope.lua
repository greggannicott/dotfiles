local wk = require("which-key")
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
wk.register({
  ["?"] = {require('telescope.builtin').oldfiles, 'Find recently opened files' },
  ["/"] = {require('telescope.builtin').current_buffer_fuzzy_find, 'Fuzzily search in current buffer' },
  s = {
    name = "Search",
    b = {require('telescope.builtin').buffers,'Search existing Buffers' },
    d = {require('telescope.builtin').diagnostics, 'Search Diagnostics' },
    f = {require('telescope.builtin').find_files, "Search git Files" },
    g = {require('telescope.builtin').live_grep, 'Search using Grep' },
    G = {function()
      local glob_pattern = vim.fn.input("File Name (GLOB Pattern) > ")
      if (glob_pattern == '') then
        return
      end
      require('telescope.builtin').live_grep({
        glob_pattern = glob_pattern
      })
    end, 'Search using Grep (Filter by File Name)' },
    h = {require('telescope.builtin').help_tags, 'Search Help' },
    r = {require('telescope.builtin').lsp_references, 'Search References' },
  },
}, { prefix = "<leader>" })

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
end, { desc = 'Find files' })

