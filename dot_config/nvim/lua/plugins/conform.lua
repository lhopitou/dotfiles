--- @module 'lazy'
--- @type LazySpec
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  dependencies = { 'mason.nvim' },
  cmd = 'ConformInfo',
  keys = {
    {
      '<leader>lf',
      function()
        require('conform').format()
        vim.cmd 'update'
      end,
      desc = 'Format buffer',
    },
    { '<leader>qf', '<cmd>cfdo lua require("conform").format() vim.cmd("update")<cr>', desc = 'Format quickfix files' },
  },
  init = function()
    local toggle = require 'snacks.toggle'
    vim.g.autoformat = true
    toggle
      .new({
        name = 'Format on save',
        get = function() return vim.g.autoformat end,
        set = function(state) vim.g.autoformat = state end,
      })
      :map '<leader>tf'
  end,
  opts = {
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = 'fallback',
    },
    format_on_save = function()
      if not vim.g.autoformat then return end
      return { lsp_format = 'fallback' }
    end,
    formatters_by_ft = {
      ['_'] = { 'trim_whitespace', lsp_format = 'prefer' },
    },
  },
}
