local map = vim.keymap.set

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'VeryLazy', 'LazyFile' },
    cmd = { 'TSUpdate', 'TSInstall', 'TSLog', 'TSUninstall' },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    init = function() vim.g.no_plugin_maps = true end,
    opts = {
      move = {
        enable = true,
        set_jumps = true,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter-textobjects').setup(opts)
      local move = require 'nvim-treesitter-textobjects.repeatable_move'
      map({ 'n', 'x', 'o' }, ';', move.repeat_last_move_next)
      map({ 'n', 'x', 'o' }, ',', move.repeat_last_move_previous)
      map({ 'n', 'x', 'o' }, 'f', move.builtin_f_expr, { expr = true })
      map({ 'n', 'x', 'o' }, 'F', move.builtin_F_expr, { expr = true })
      map({ 'n', 'x', 'o' }, 't', move.builtin_t_expr, { expr = true })
      map({ 'n', 'x', 'o' }, 'T', move.builtin_T_expr, { expr = true })

      local next_start = require('nvim-treesitter-textobjects.move').goto_next_start
      local next_end = require('nvim-treesitter-textobjects.move').goto_next_end
      local previous_start = require('nvim-treesitter-textobjects.move').goto_previous_start
      local previous_end = require('nvim-treesitter-textobjects.move').goto_previous_end
      map({ 'n', 'x', 'o' }, ']f', function() next_start('@function.outer', 'textobjects') end, { desc = 'Next function' })
      map({ 'n', 'x', 'o' }, '[f', function() previous_start('@function.outer', 'textobjects') end, { desc = 'Previous function' })
      map({ 'n', 'x', 'o' }, ']c', function()
        if vim.wo.diff then return vim.cmd 'normal! ]c' end
        next_start('@class.outer', 'textobjects')
      end, { desc = 'Next class' })
      map({ 'n', 'x', 'o' }, '[c', function()
        if vim.wo.diff then return vim.cmd 'normal! [c' end
        previous_start('@class.outer', 'textobjects')
      end, { desc = 'Previous class' })
      map({ 'n', 'x', 'o' }, ']r', function() next_start('@return.outer', 'textobjects') end, { desc = 'Next return' })
      map({ 'n', 'x', 'o' }, '[r', function() previous_start('@return.outer', 'textobjects') end, { desc = 'Previous return' })
      map({ 'n', 'x', 'o' }, ']a', function() next_start('@parameter.inner', 'textobjects') end, { desc = 'Next parameter' })
      map({ 'n', 'x', 'o' }, '[a', function() previous_start('@parameter.inner', 'textobjects') end, { desc = 'Previous parameter' })
      map({ 'n', 'x', 'o' }, ']t', function() next_start('@jsx_element.outer', 'textobjects') end, { desc = 'Next tag' })
      map({ 'n', 'x', 'o' }, '[t', function() previous_start('@jsx_element.outer', 'textobjects') end, { desc = 'Previous tag' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'LazyFile',
    opts = {
      multiwindow = true,
      multiline_threshold = 1,
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      map('n', 'gp', function() require('treesitter-context').go_to_context(vim.v.count1) end, { desc = 'Go to context parent', silent = true })
      map('n', 'gP', function() require('treesitter-context').go_to_context(99) end, { desc = 'Go to root context parent', silent = true })
    end,
  },
}
