---@module 'lazy'
---@type LazySpec
return {
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- nvim-lspconfig v2 needs no setup(); per-server settings live in
      -- `lua/lsp/<server>.lua` and are merged by `vim.lsp.config` from rtp.
      { 'neovim/nvim-lspconfig', config = function() end },
      'mason-org/mason.nvim',
      'SmiteshP/nvim-navic',
    },
    opts = { automatic_enable = { exclude = {} } },
  },
  {
    'mason-org/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    -- list opts append across specs, so `lua/plugins/lang/*.lua` can add tools
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {},
    },
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger {
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          }
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end)
    end,
  },
  {
    'SmiteshP/nvim-navic',
    lazy = true,
    opts = {
      lsp = { auto_attach = true },
    },
    config = function(_, opts)
      local navic = require 'nvim-navic'
      navic.setup(opts)

      local goto_parent = function(top)
        if not navic.is_available() then return end
        local data = navic.get_data()
        if #data == 0 then return end
        local count = math.min(vim.v.count1, #data)
        local target
        if top then
          target = data[count]
        else
          target = data[#data - count + 1]
        end
        vim.cmd "normal! m'"
        vim.api.nvim_win_set_cursor(0, { target.scope.start.line, target.scope.start.character })
      end

      local map = vim.keymap.set
      map('n', 'gp', function() goto_parent(false) end, { desc = 'Go to root parent' })
      map('n', 'gP', function() goto_parent(true) end, { desc = 'Go to parent' })
    end,
  },
}
