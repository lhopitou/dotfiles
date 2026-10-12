return {
  {
    'mason-org/mason-lspconfig.nvim',
    opts = function(_, opts)
      table.insert(opts.automatic_enable.exclude, 'stylua')
      return opts
    end,
  },
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'lua-language-server', 'stylua' },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },
}
