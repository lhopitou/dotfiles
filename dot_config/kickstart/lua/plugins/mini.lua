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
  {
    'nvim-mini/mini.clue',
    opts = function()
      local MiniClue = require 'mini.clue'

      -- Built-in text objects (`iw`, `a(`, ...) are not keymaps at all, and
      -- mini.ai only maps the `a`/`i` prefixes (as expr mappings) and resolves
      -- the object key itself, so there are no `if`/`af`/... mappings either.
      -- mini.clue can only show real mappings and explicitly registered
      -- clues, so text objects need manual clues
      -- (:h mini-clue -> "Clues without mappings").
      local textobjects = {
        { key = 'w', desc = 'word' },
        { key = 'W', desc = 'WORD' },
        { key = 'p', desc = 'paragraph' },
        { key = 's', desc = 'sentence' },
        { key = 'b', desc = 'brackets (), [], {}' }, -- mini.ai alias
        { key = '(', desc = '(...) block' },
        { key = ')', desc = '(...) block' },
        { key = '[', desc = '[...] block' },
        { key = ']', desc = '[...] block' },
        { key = '{', desc = '{...} block' },
        { key = '}', desc = '{...} block' },
        { key = '<', desc = '<...> block' },
        { key = '>', desc = '<...> block' },
        { key = 'q', desc = 'quotes " ' .. "'" .. ' `' }, -- mini.ai alias
        { key = '"', desc = '"..." string' },
        { key = "'", desc = "'...' string" },
        { key = '`', desc = '`...` string' },
        { key = 'a', desc = 'argument' }, -- mini.ai
        { key = '_', desc = 'trailing whitespace' }, -- mini.ai "default" object
        { key = '?', desc = 'user prompt' }, -- mini.ai
        -- custom mini.ai textobjects (see mini.ai spec above)
        { key = 'f', desc = 'function (treesitter)' },
        { key = 'c', desc = 'class (treesitter)' },
        { key = 'r', desc = 'return block (treesitter)' },
        { key = 't', desc = 'JSX element' },
      }

      -- nvim-surround delimiter keys it accepts as `cs`/`ds` targets (its
      -- `surrounds` + `aliases`); these are read via getchar()/g@, so again
      -- there are no mappings for mini.clue to discover.
      local surround_pairs = {
        { key = '(', desc = '(...)' },
        { key = ')', desc = '(...)' },
        { key = '[', desc = '[...]' },
        { key = ']', desc = '[...]' },
        { key = '{', desc = '{...}' },
        { key = '}', desc = '{...}' },
        { key = '<', desc = '<...>' },
        { key = '>', desc = '<...>' },
        { key = '"', desc = '"..."' },
        { key = "'", desc = "'...'" },
        { key = '`', desc = '`...`' },
        { key = 'b', desc = 'alias )' },
        { key = 'B', desc = 'alias }' },
        { key = 'r', desc = 'alias ]' },
        { key = 'a', desc = 'alias >' },
        { key = 'q', desc = 'alias quotes' },
        { key = 's', desc = 'alias any pair' },
        { key = 't', desc = 'HTML/XML tag' },
        { key = 'T', desc = 'HTML/XML tag (inner)' },
        { key = 'f', desc = 'function call' },
      }

      local clues = {
        -- Enhance this by adding descriptions for <Leader> mapping groups
        MiniClue.gen_clues.square_brackets(),
        MiniClue.gen_clues.builtin_completion(),
        MiniClue.gen_clues.g(),
        MiniClue.gen_clues.marks(),
        MiniClue.gen_clues.registers(),
        MiniClue.gen_clues.windows(),
        MiniClue.gen_clues.z(),
        { mode = 'n', keys = '<leader>b', desc = '+buffer' },
        { mode = 'n', keys = '<leader>c', desc = '+code' },
        { mode = 'n', keys = '<leader>f', desc = '+find' },
        { mode = 'n', keys = '<leader>g', desc = '+git' },
        { mode = 'n', keys = '<leader>l', desc = '+lsp' },
        { mode = 'n', keys = '<leader>q', desc = '+quickfix' },
        { mode = 'n', keys = '<leader>s', desc = '+search' },
        { mode = 'n', keys = '<leader>w', desc = '+window' },
        { mode = 'n', keys = '<leader>z', desc = '+quit' },
      }

      -- Text objects in Visual and Operator-pending mode. The `o` clues also
      -- apply after `ys`/`yS` from nvim-surround, which read their motion via
      -- the `g@` operator (Operator-pending).
      for _, mode in ipairs { 'o', 'x' } do
        for _, prefix in ipairs { 'i', 'a' } do
          for _, obj in ipairs(textobjects) do
            clues[#clues + 1] = {
              mode = mode,
              keys = prefix .. obj.key,
              desc = (prefix == 'i' and 'Inside ' or 'Around ') .. obj.desc,
            }
          end
        end
      end

      -- nvim-surround `ys{motion}{char}` targets. Plain motions (`ys$`, `ysj`,
      -- ...) still work: keys not listed here execute immediately.
      clues[#clues + 1] = { mode = 'n', keys = 'ysi', desc = '+inside text object' }
      clues[#clues + 1] = { mode = 'n', keys = 'ysa', desc = '+around text object' }
      for _, prefix in ipairs { 'i', 'a' } do
        for _, obj in ipairs(textobjects) do
          clues[#clues + 1] = {
            mode = 'n',
            keys = 'ys' .. prefix .. obj.key,
            desc = 'Surround ' .. (prefix == 'i' and 'inside ' or 'around ') .. obj.desc,
          }
        end
      end

      -- nvim-surround `ds{char}` / `cs{char}` targets. (For `cs` the
      -- replacement char is then requested via input() prompt, which can't be
      -- hinted by mini.clue.)
      for _, pair in ipairs(surround_pairs) do
        clues[#clues + 1] = { mode = 'n', keys = 'ds' .. pair.key, desc = 'Delete surrounding ' .. pair.desc }
        clues[#clues + 1] = { mode = 'n', keys = 'cs' .. pair.key, desc = 'Change surrounding ' .. pair.desc }
        clues[#clues + 1] = { mode = 'n', keys = 'yss' .. pair.key, desc = 'Change surrounding ' .. pair.desc }
        clues[#clues + 1] = { mode = 'x', keys = 'S' .. pair.key, desc = 'Add surrounding ' .. pair.desc }
      end

      return {
        triggers = {
          -- Leader triggers
          { mode = { 'n', 'x' }, keys = '<Leader>' },

          -- `[` and `]` keys
          { mode = 'n', keys = '[' },
          { mode = 'n', keys = ']' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = { 'n', 'x' }, keys = 'g' },

          -- Marks
          { mode = { 'n', 'x' }, keys = "'" },
          { mode = { 'n', 'x' }, keys = '`' },

          -- Registers
          { mode = { 'n', 'x' }, keys = '"' },
          { mode = { 'i', 'c' }, keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = { 'n', 'x' }, keys = 'z' },

          -- Textobjects. NOTE: only the *prefixes* are triggers; the actual
          -- object keys (`iw`, `af`, `it`, ...) are hinted via explicit clues
          -- built from `textobjects` above.
          { mode = 'x', keys = 'a' },
          { mode = 'x', keys = 'i' },
          { mode = 'o', keys = 'a' },
          { mode = 'o', keys = 'i' },

          -- nvim-surround. `yss`/`yS`/`ySS` are real mappings and show up
          -- automatically; the sub-keys are covered by the clues above.
          { mode = 'n', keys = 'ys' },
          { mode = 'n', keys = 'cs' },
          { mode = 'n', keys = 'ds' },
          { mode = 'x', keys = 'S' },
        },
        clues = clues,
        window = {
          delay = 500,
        },
      }
    end,
  },
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
