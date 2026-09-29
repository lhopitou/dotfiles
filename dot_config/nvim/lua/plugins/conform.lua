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
  opts = {
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = 'fallback',
    },
    format_on_save = {
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      ['_'] = { 'trim_whitespace', lsp_format = 'prefer' },
    },
  },
}
