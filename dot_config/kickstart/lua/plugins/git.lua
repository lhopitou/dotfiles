---@module 'lazy'
---@type LazySpec
return {
  {
    'lewis6991/gitsigns.nvim',
    event = 'LazyFile',
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
      on_attach = function(buffer)
        local gs = require 'gitsigns'

        local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true }) end

        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gs.nav_hunk 'next'
          end
        end, 'Next hunk')
        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gs.nav_hunk 'prev'
          end
        end, 'Prev hunk')
        map('n', ']H', function() gs.nav_hunk 'last' end, 'Last hunk')
        map('n', '[H', function() gs.nav_hunk 'first' end, 'First hunk')
        map({ 'n', 'x' }, '<leader>gs', ':Gitsigns stage_hunk<CR>', 'Stage hunk')
        map({ 'n', 'x' }, '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', 'Undo Stage hunk')
        map({ 'n', 'x' }, '<leader>gr', ':Gitsigns reset_hunk<CR>', 'Reset hunk')
        map('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
        map('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
        map('n', '<leader>gb', function() gs.blame_line { full = true } end, 'Blame Line')
        map('n', '<leader>gB', function() gs.blame() end, 'Blame buffer')
      end,
    },
  },
  {
    'dlyongemallo/diffview-plus.nvim',
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr> -- %', desc = 'Diff' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'View file commit history' },
    },
    opts = {
      view = {
        merge_tool = { layout = 'diff3_mixed' },
      },
      file_panel = {
        listing_style = 'list',
      },
      diffopt = { algorithm = 'histogram' },
      keymaps = {
        view = {
          { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
        },
        file_panel = {
          { 'n', 'q', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' } },
        },
        file_history_panel = {
          { 'n', 'q', '<cmd>DiffviewClose<cr>', desc = 'Close diffview' },
        },
      },
    },
  },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'dlyongemallo/diffview-plus.nvim',
      'ibhagwan/fzf-lua',
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neogit' },
    },
  },
}
