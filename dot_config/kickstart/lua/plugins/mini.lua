---@module 'lazy'
---@type LazySpec
return {
  {
    'nvim-mini/mini.ai',
    version = '*',
    event = 'VeryLazy',
    opts = function()
      -- JSX element textobject (`vit` / `vat`).
      -- mini.ai's cover-based selection can't do "inner of the element under the
      -- cursor" for JSX: an element's inner range starts after its opening tag,
      -- so it never covers an on-tag cursor, and mini.ai falls back to the
      -- parent's inner. For a single-child element this is especially wrong
      -- because the parent's inner range equals this element's outer range, so
      -- `vit` on the tag selects the element *with* its tags (= `vat`). This
      -- spec instead finds the smallest `jsx_element` whose outer range covers
      -- the cursor and returns *that element's own* inner range (its children,
      -- excluding the open/close tags) — correct on every tag including
      -- single-child elements. `f`/`c`/`r` use gen_spec.treesitter below (their
      -- inner *is* the body containing the cursor, so cover works); `q` (quotes)
      -- and brackets stay on mini.ai builtins.
      local function jsx_textobject(ai_type)
        local buf = vim.api.nvim_get_current_buf()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1
        local ok, parser = pcall(vim.treesitter.get_parser, buf)
        if not ok or not parser then return {} end
        parser:parse()
        local lang_tree = parser:language_for_range { row, col, row, col }

        local best, best_size
        for _, tree in ipairs(lang_tree:trees()) do
          local function walk(node)
            if node:type() == 'jsx_element' then
              local srow, scol, erow, ecol = node:range()
              local covers = (srow < row or (srow == row and scol <= col)) and (erow > row or (erow == row and ecol >= col))
              if covers then
                local size = (erow - srow) * 100000 + (ecol - scol)
                if best_size == nil or size < best_size then
                  best_size = size
                  if ai_type == 'a' then
                    best = { from = { line = srow + 1, col = scol + 1 }, to = { line = erow + 1, col = ecol } }
                  else
                    local children = {}
                    for child in node:iter_children() do
                      local ct = child:type()
                      if ct ~= 'jsx_opening_element' and ct ~= 'jsx_closing_element' then children[#children + 1] = child end
                    end
                    if #children > 0 then
                      local csrow, cscol = children[1]:range()
                      local _, _, cerow, cecol = children[#children]:range()
                      best = { from = { line = csrow + 1, col = cscol + 1 }, to = { line = cerow + 1, col = cecol } }
                    end
                  end
                end
              end
            end
            for child in node:iter_children() do
              walk(child)
            end
          end
          walk(tree:root())
        end
        if best == nil then return {} end
        return { best }
      end

      local ai = require 'mini.ai'
      local ts_spec = ai.gen_spec.treesitter
      return {
        n_lines = 500,
        custom_textobjects = {
          f = ts_spec { a = '@function.outer', i = '@function.inner' },
          c = ts_spec { a = '@class.outer', i = '@class.inner' },
          r = ts_spec { a = '@return.outer', i = '@return.inner' },
          t = jsx_textobject,
        },
      }
    end,
  },
  {
    'nvim-mini/mini.animate',
    event = 'VeryLazy',
    cond = vim.g.neovide == nil,
    opts = function(_, opts)
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs { 'Up', 'Down' } do
        local key = '<ScrollWheel' .. scroll .. '>'
        vim.keymap.set({ '', 'i' }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'grug-far',
        callback = function() vim.b.minianimate_disable = true end,
      })

      local animate = require 'mini.animate'
      return vim.tbl_deep_extend('force', opts, {
        resize = {
          timing = animate.gen_timing.linear { duration = 50, unit = 'total' },
        },
        scroll = {
          timing = animate.gen_timing.linear { duration = 150, easing = 'out', unit = 'total' },
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
        cursor = { enable = false },
      })
    end,
  },
  -- {
  --   'nvim-mini/mini.clue',
  --   opts = {
  --     triggers = {
  --       -- Leader triggers
  --       { mode = { 'n', 'x' }, keys = '<Leader>' },
  --
  --       -- `[` and `]` keys
  --       { mode = 'n', keys = '[' },
  --       { mode = 'n', keys = ']' },
  --
  --       -- Built-in completion
  --       { mode = 'i', keys = '<C-x>' },
  --
  --       -- `g` key
  --       { mode = { 'n', 'x' }, keys = 'g' },
  --
  --       -- Marks
  --       { mode = { 'n', 'x' }, keys = "'" },
  --       { mode = { 'n', 'x' }, keys = '`' },
  --
  --       -- Registers
  --       { mode = { 'n', 'x' }, keys = '"' },
  --       { mode = { 'i', 'c' }, keys = '<C-r>' },
  --
  --       -- Window commands
  --       { mode = 'n', keys = '<C-w>' },
  --
  --       -- `z` key
  --       { mode = { 'n', 'x' }, keys = 'z' },
  --     },
  --   },
  --   config = function(_, opts)
  --     local MiniClue = require 'mini.clue'
  --     opts.clues = {
  --       { mode = 'n', keys = '<leader>b', desc = '+buffer' },
  --       { mode = 'n', keys = '<leader>c', desc = '+code' },
  --       { mode = 'n', keys = '<leader>f', desc = '+find' },
  --       { mode = 'n', keys = '<leader>g', desc = '+git' },
  --       { mode = 'n', keys = '<leader>l', desc = '+lsp' },
  --       { mode = 'n', keys = '<leader>q', desc = '+quickfix' },
  --       { mode = 'n', keys = '<leader>s', desc = '+search' },
  --       { mode = 'n', keys = '<leader>w', desc = '+window' },
  --       { mode = 'n', keys = '<leader>z', desc = '+quit' },
  --       -- Enhance this by adding descriptions for <Leader> mapping groups
  --       MiniClue.gen_clues.square_brackets(),
  --       MiniClue.gen_clues.builtin_completion(),
  --       MiniClue.gen_clues.g(),
  --       MiniClue.gen_clues.marks(),
  --       MiniClue.gen_clues.registers(),
  --       MiniClue.gen_clues.windows(),
  --       MiniClue.gen_clues.z(),
  --     }
  --     MiniClue.setup(opts)
  --   end,
  -- },
  {
    'nvim-mini/mini.icons',
    version = '*',
    lazy = true,
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'nvim-mini/mini.indentscope',
    event = 'LazyFile',
    opts = {
      symbol = '⁚',
      options = {
        try_as_border = true,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'fzf',
          'help',
          'lazy',
          'mason',
          'snacks_dashboard',
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SnacksDashboardOpened',
        callback = function(data) vim.b[data.buf].miniindentscope_disable = true end,
      })
    end,
    config = function(_, opts)
      require('mini.indentscope').setup(opts)
      -- Change color here
      -- vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'Comment' })
    end,
  },
  {
    'nvim-mini/mini.pairs',
    event = 'VeryLazy',
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
    },
  },
}
