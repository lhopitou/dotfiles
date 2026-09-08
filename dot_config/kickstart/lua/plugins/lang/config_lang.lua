return {
  {
    'mason-org/mason.nvim',
    opts = {
      ensure_installed = { 'json-lsp', 'yaml-language-server', 'taplo' },
    },
  },
  {
    'b0o/SchemaStore.nvim',
    lazy = true,
  },
}
