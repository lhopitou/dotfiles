return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  event = { 'InsertEnter', 'CmdlineEnter' },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = { preset = 'super-tab' },
    completion = {
      trigger = { show_in_snippet = false },
      ghost_text = { enabled = true },
    },
    signature = {
      enabled = true,
    },
    cmdline = {
      keymap = { preset = 'inherit' },
      completion = { menu = { auto_show = true } },
    },
  },
  opts_extend = { 'sources.default' },
}
