return {
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'tsc', 'prettierd', 'prettier', 'tailwindcss-language-server', 'js-debug-adapter' },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        scss = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'LazyFile',
    opts = {},
  },
  {
    'mfussenegger/nvim-dap',
    opts = {
      adapters = {
        ['pwa-node'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = { command = vim.fn.exepath 'js-debug-adapter', args = { '${port}' } },
        },
      },
    },
  },
}
