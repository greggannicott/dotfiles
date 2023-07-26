local wk = require('which-key')

require('gitsigns').setup({

  -- See `:help gitsigns.txt`
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    -- Note: the 'which' description for these mappings are handled below as you were
    -- unable to get which-key.register to work within the on_attach.
    vim.keymap.set('n', '<leader>ghp', require('gitsigns').prev_hunk,
      { buffer = bufnr })
    vim.keymap.set('n', '<leader>ghn', require('gitsigns').next_hunk, { buffer = bufnr })
    vim.keymap.set('n', '<leader>ghv', require('gitsigns').preview_hunk, { buffer = bufnr })
    vim.keymap.set('n', '<leader>ghs', require('gitsigns').stage_hunk, { buffer = bufnr })
    vim.keymap.set('n', '<leader>ghr', require('gitsigns').reset_hunk, { buffer = bufnr })
  end,
})

wk.register({
  ['['] = {
    h = { require('gitsigns').prev_hunk, 'Previous hunk' },
  },
  [']'] = {
    h = { require('gitsigns').next_hunk, 'Next hunk' },
  },
  ['<leader>'] = {
    g = {
      name = "Git",
      b = { ':Gitsigns toggle_current_line_blame<CR>', 'Toggle Line Blame' },
      g = { ':Git<CR>', 'Git Status' },
      c = {
        name = "Commit",
        c = { ':Git commit<CR>', 'Git Commit' },
        a = { ':Git commit --amend<CR>', 'Git Commit Amend' },
      },
      h = {
        name = "Hunk",
        p = "Previous Hunk",
        n = "Next Hunk",
        v = "View Hunk",
        s = "Stage Hunk",
        r = "Reset Hunk"
      },
      d = {
        name = "Diff",
        b = { ':DiffviewOpen origin/main... --imply-local<CR>', "Diff branch with main" }
      }
    },
  }
}, {})
