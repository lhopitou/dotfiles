return {
  {
    'EdenEast/nightfox.nvim',
    opts = {
      options = {
        modules = {
          diagnostic = {
            background = false,
          },
          native_lsp = {
            background = false,
          },
        },
      },
      groups = {
        all = {
          NavicIconsArray = { link = 'NavicIconsObject' },
        },
      },
    },
  },
  {
    'catppuccin/nvim',
  },
}
