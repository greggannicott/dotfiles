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
        vim.keymap.set('n', '<leader>ph', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[P]revious [H]unk' })
        vim.keymap.set('n', '<leader>nh', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[N]ext [H]unk' })
        vim.keymap.set('n', '<leader>gh', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview [G]it [H]unk' })
        vim.keymap.set('n', '<leader>gsh', require('gitsigns').stage_hunk, { buffer = bufnr, desc = 'Stage Git Hunk' })
        vim.keymap.set('n', '<leader>grh', require('gitsigns').reset_hunk, { buffer = bufnr, desc = 'Reset Git Hunk' })
      end,
})
