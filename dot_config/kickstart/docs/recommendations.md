# Config Recommendations

Ideas gathered from a review of this config, ordered by priority. Sections:
[Quick wins](#quick-wins-pluginsmodules-you-already-have) ·
[Real gaps](#real-gaps) ·
[Quality of life](#quality-of-life) ·
[Snippets](#snippets-recommendation-luasnip) ·
[Optional](#optional--situational)

## Quick wins (plugins/modules you already have)

### 1. Terminal

No terminal integration currently. `snacks.terminal` is already in the bundle, just not enabled:

```lua
-- lua/plugins/snacks.lua
opts = {
  terminal = { enabled = true },
  toggle = { enabled = true },
  -- ...
}
```

Map `<c-/>` or `<leader>tt` to a floating terminal. Biggest daily-life improvement available.

### 2. guess-indent.nvim

`options.lua` already says tabs "should be overridden by guess-indent" — but the plugin isn't installed. Add it so mixed-indent projects stop fighting the `shiftwidth = 2` default.

```lua
{
  'NMAC427/guess-indent.nvim',
  event = 'LazyFile',
  opts = {},
}
```

### 3. Sessions

`sessionoptions` is configured carefully, but nothing saves or restores sessions. Pick one:

- `snacks.pro` (experimental)
- `persistence.nvim`
- `auto-session`

### 4. Small snacks modules

One-liners with what's already installed:

- `snacks.gitbrowse` — open file/repo on GitHub
- `snacks.scratch` — throwaway scratch buffers
- `<leader>fs` → `FzfLua lsp_document_symbols` — cheap and heavily used

## Real gaps

### 5. nvim-lint

Formatting is handled (conform) but linting isn't. `nvim-lint` lints on `BufWritePost`, mirroring conform's `BufWritePre`. Covers `markdownlint`, `shellcheck`, `eslint_d`, etc. without a dedicated LSP.

### 6. trouble.nvim

Diagnostics can be jumped one at a time (`]d`/`[d`); a project-wide list view is the missing half. Alternatively add a keymap to `FzfLua diagnostics` if avoiding another plugin.

### 7. Debugging (nvim-dap)

The biggest actual gap. `nvim-dap` + `nvim-dap-ui` + language adapters. Better to set up before you need it.

### 8. Test running

`neotest` or `vim-test` + keymaps for nearest-test run/debug. Pairs naturally with #7.

## Quality of life

9. **Motion** — no jump-anywhere plugin. `flash.nvim` or `mini.jump` / `mini.jump2d` (keeps the mini.* family consistent).
10. **vim-matchup** — treesitter-aware `%` and `goto #if/#end`. Tiny, no config.
11. **yanky.nvim** — yank ring + `<p>`/`<P>` indent-preserving put. Fits the existing cursor-position ergonomics (`y` → `myy\`y`).
12. **render-markdown.nvim** — inline-rendered markdown headings/bullets; markdown files already get `wrap` + `spell`.

## Snippets (recommendation: LuaSnip)

Best fit for this stack: the only engine with **native blink.cmp support**, and fzf-lua ships a **built-in LuaSnip picker** (`:FzfLua luasnip`). Custom snippets are just Lua files in the config.

*Alternative:* `mini.snippets` — simpler authoring and lookup via `vim.ui.select`, consistent with the mini.* family. Tradeoff: no official blink.cmp source (would need `blink.compat`, less polished). Given blink + fzf-lua drive the editing UX, LuaSnip is the pragmatic pick.

### Plugin

```lua
-- lua/plugins/snippets.lua
return {
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp', -- better regex for trigger patterns
    event = 'InsertEnter',
    opts = {
      history = true, -- jumping back into a snippet you left
      delete_check_events = 'TextChanged',
    },
    keys = {
      { '<c-k>', function() require('luasnip').jump(1) end, mode = { 'i', 's' }, desc = 'Next snippet node' },
      { '<c-j>', function() require('luasnip').jump(-1) end, mode = { 'i', 's' }, desc = 'Prev snippet node' },
    },
    config = function(_, opts)
      local luasnip = require 'luasnip'
      luasnip.config.setup(opts)
      require('luasnip.loaders.from_lua').load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
    end,
  },
}
```

### Wire into blink.cmp

In `lua/plugins/blink.lua`:

```lua
opts = {
  snippets = { preset = 'luasnip' },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets' },
  },
  -- ...
}
```

blink handles expansion + node-jumping; the `<c-k>`/`<c-j>` maps handle jumps outside completion too.

### Lookup via fzf-lua

One keymap in the fzf spec — zero extra code:

```lua
{ '<leader>sn', '<cmd>FzfLua luasnip<cr>', desc = 'Snippets' },
```

Lists all snippets available for the current filetype; selecting one expands it at the cursor.

### Custom snippets

Filetype = filename. Example `snippets/lua.lua`:

```lua
local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt

return {
  s('mod', fmt('local {} = require {}\n{}', { i(1), i(2, 'mod'), i(0) })),
  s('fn', fmt('function {}({})\n{}\nend', { i(1, 'name'), i(2), i(0) })),
  s('date', f(function() return os.date '%Y-%m-%d' end)),
}
```

- Full node types available (choices, dynamic, regex captures)
- Autotrigger available: `ls.snippet({ trig = '...', snippetType = 'autotrigger' })`
- VS Code JSON (friendly-snippets) loads via `luasnip.loaders.from_vscode` — already a blink dependency, so the ecosystem is available if wanted

## Optional / situational

- **CodeCompanion or similar** — AI-assist, only if wanted in-editor
- **overseer.nvim** — task runner (`make`, `cargo build`, ...); or just `fzf-lua` + `:make` if needs are light
- **gitlinker** — copy GitHub permalink under cursor; slots right into the git-heavy setup (neogit + diffview + gitsigns)

## If picking only three

1. Terminal (#1)
2. nvim-lint (#5)
3. Sessions (#3)

These cover actual daily workflows that are currently missing; the rest is polish.
