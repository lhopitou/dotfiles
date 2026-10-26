return {
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'jdtls', 'java-debug-adapter', 'vscode-spring-boot-tools' },
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
    lazy = true,
    dependencies = { 'mfussenegger/nvim-dap' },
  },
  {
    'JavaHello/spring-boot.nvim',
    ft = { 'java', 'yaml', 'jproperties' },
    dependencies = {
      'mfussenegger/nvim-jdtls',
      'ibhagwan/fzf-lua',
    },
    opts = {
      java_cmd = vim.fn.has_key(vim.fn.environ(), 'SDKMAN_DIR') and vim.fn.expand '$SDKMAN_DIR/candidates/java/current/bin/java'
        or vim.fn.expand '$JAVA_HOME/bin/java',
    },
  },
  {
    'ishi-o/nvim-mybatis',
    lazy = true,
    opts = {},
  },
}
