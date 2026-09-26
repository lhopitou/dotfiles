return {
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'gofumpt', 'goimports', 'gopls' },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        go = { 'goimports', 'gofumpt' },
      },
    },
  },
}
