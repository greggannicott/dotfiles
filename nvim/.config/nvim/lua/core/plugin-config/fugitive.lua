-- Example mapping for Gstatus in normal mode
vim.api.nvim_set_keymap('n', '<Leader>gg', ':Git<CR>', { desc = '[G]it' } )
vim.api.nvim_set_keymap('n', '<Leader>gc', ':Git commit<CR>', { desc = '[G]it [C]ommit' } ) 
vim.api.nvim_set_keymap('n', '<Leader>ga', ':Git commit --amend<CR>', { desc = '[G]it [A]mend Commit' } ) 

