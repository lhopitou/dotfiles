return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      auto_integrations = true,
    },
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    name = "oxocarbon",
    priority = 1000,
    build = false,
  },
  {
    "nendix/zen.nvim",
    name = "zen",
    priority = 1000,
  },
  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    opts = function()
      local C = require("nightfox.lib.color")
      local fg = C("#e2e2e2")
      return {
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
        palettes = {
          carbonfox = {
            -- fg0 = fg:brighten(6):to_css(), -- Lighter fg
            -- fg1 = fg:to_css(), -- Default fg
            -- fg2 = fg:brighten(-24):to_css(), -- Darker fg (status line)
            -- fg3 = fg:brighten(-48):to_css(), -- Darker fg (line numbers, fold colums)
            sel0 = "#3b3b3b", -- Darker fg (line numbers, fold colums)
          },
        },
      }
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "carbonfox",
    },
  },
}
