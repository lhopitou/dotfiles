return {
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'jdtls' },
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = function(_, opts)
      table.insert(opts.automatic_enable.exclude, 'jdtls')
      return opts
    end,
  },
  {
    'mfussenegger/nvim-jdtls',
  },
}
