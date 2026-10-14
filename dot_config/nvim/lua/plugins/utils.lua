---@module 'lazy'
---@type LazySpec
return {
  -- {
  --   'folke/which-key.nvim',
  --   event = 'VeryLazy',
  --   opts = {
  --     preset = 'helix',
  --     delay = '500',
  --     spec = {
  --       mode = { 'n', 'x' },
  --       { '<leader>b', group = 'buffer' },
  --       { '<leader>c', group = 'code' },
  --       { '<leader>f', group = 'find' },
  --       { '<leader>g', group = 'git' },
  --       { '<leader>l', group = 'lsp' },
  --       { '<leader>q', group = 'quickfix' },
  --       { '<leader>s', group = 'search' },
  --       { '<leader>w', group = 'window' },
  --       { '<leader>z', group = 'quit' },
  --     },
  --   },
  --   keys = {
  --     { '<leader>?', function() require('which-key').show { global = false } end, desc = 'Buffer Keymaps' },
  --   },
  -- },
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
      { '<leader>ts', '<cmd>TSJToggle<cr>', desc = 'Toggle block split' },
    },
    opts = {
      use_default_keymaps = false,
    },
  },
  {
    'rachartier/tiny-cmdline.nvim',
    init = function() vim.o.cmdheight = 0 end,
    opts = function()
      local cmdline = require 'tiny-cmdline'
      return {
        position = {
          y = '15%',
        },
        menu_col_offset = 1,
        native_types = {},
        title = {
          enabled = true,
        },
        on_reposition = cmdline.adapters.blink,
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
