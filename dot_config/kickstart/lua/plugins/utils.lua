---@module 'lazy'
---@type LazySpec
return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      delay = '500',
      spec = {
        mode = { 'n', 'x' },
        { '<leader>b', group = 'buffer' },
        { '<leader>c', group = 'code' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>l', group = 'lsp' },
        { '<leader>q', group = 'quickfix' },
        { '<leader>s', group = 'search' },
        { '<leader>w', group = 'window' },
        { '<leader>z', group = 'quit' },
      },
    },
    keys = {
      { '<leader>?', function() require('which-key').show { global = false } end, desc = 'Buffer Keymaps' },
    },
  },
  {
    'MagicDuck/grug-far.nvim',
    keys = {
      { '<leader>sr', ':GrugFar<cr>', desc = 'Search and replace' },
    },
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
  },
  {
    'wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { '<leader>ts', '<cmd>TSJSplit<cr>', desc = 'Split tree' },
      { '<leader>tj', '<cmd>TSJJoin<cr>', desc = 'Join tree' },
      { '<leader>tt', '<cmd>TSJToggle<cr>', desc = 'Toggle tree' },
    },
    opts = {
      use_default_keymaps = false,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
