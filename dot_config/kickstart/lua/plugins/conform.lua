--- @module 'lazy'
--- @type LazySpec
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  dependencies = { 'mason.nvim' },
  cmd = 'ConformInfo',
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
    },
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = 'fallback',
    },
    format_on_save = {
      lsp_format = 'fallback',
    },
  },
}
