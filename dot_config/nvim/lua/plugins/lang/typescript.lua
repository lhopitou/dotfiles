return {
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'tsc', 'prettierd', 'tailwindcss-language-server', 'js-debug-adapter' },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        html = { 'prettierd' },
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
