--- @module 'lazy'
--- @type LazySpec
return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    opts = function()
      local Fzflua = require 'fzf-lua'
      return {
        'default',
        actions = {
          files = {
            true,
            ['ctrl-i'] = Fzflua.actions.toggle_ignore,
            ['ctrl-h'] = Fzflua.actions.toggle_hidden,
          },
        },
      }
    end,
    keys = {
      { '<leader><space>', '<cmd>FzfLua files<cr>', desc = 'Find files' },
      { '<leader>,', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
      { '<leader>/', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { '<leader>/', '<cmd>FzfLua grep_visual<cr>', mode = 'v', desc = 'Grep visual' },

      { '<leader>bc', '<cmd>FzfLua git_bcommits<cr>', desc = 'View buffer commits' },
      { '<leader>bu', '<cmd>FzfLua undotree<cr>', desc = 'Undotree' },

      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Find buffers' },
      { '<leader>fo', '<cmd>FzfLua oldfiles<cr>', desc = 'Find oldfiles' },
      { '<leader>fh', '<cmd>FzfLua helptags<cr>', desc = 'Find help' },
      { '<leader>fk', '<cmd>FzfLua keymaps<cr>', desc = 'Find keymaps' },
      { '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'Find LSP document symbols' },

      { '<leader>sg', '<cmd>FzfLua live_grep<cr>', desc = 'Live grep' },
      { '<leader>sw', '<cmd>FzfLua grep_cword<cr>', desc = 'Search word under cursor' },
      { '<leader>sW', '<cmd>FzfLua grep_cWORD<cr>', desc = 'Search WORD under cursor' },
      { '<leader>s', '<cmd>FzfLua grep_visual<cr>', mode = 'v', desc = 'Grep visual' },
    },
  },
}
