-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard:append 'unnamedplus'

  -- Fix "waiting for osc52 response from terminal" message
  -- https://github.com/neovim/neovim/issues/28611

  if vim.env.SSH_TTY ~= nil then
    -- Set up clipboard for ssh

    local function my_paste(_)
      return function(_)
        local content = vim.fn.getreg '"'
        return vim.split(content, '\n')
      end
    end

    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        ['+'] = require('vim.ui.clipboard.osc52').copy '+',
        ---@diagnostic disable-next-line: assign-type-mismatch
        ['*'] = require('vim.ui.clipboard.osc52').copy '*',
      },
      paste = {
        -- No OSC52 paste action since wezterm doesn't support it
        -- Should still paste from nvim
        ---@diagnostic disable-next-line: assign-type-mismatch
        ['+'] = my_paste '+',
        ---@diagnostic disable-next-line: assign-type-mismatch
        ['*'] = my_paste '*',
      },
    }
  end
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '-', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'nosplit'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 4

-- Add characters to set used to identify words
---@diagnostic disable-next-line: undefined-field
vim.opt.iskeyword:append { '-' }

vim.opt.fillchars = {
  -- foldopen = '',
  foldopen = ' ',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

if vim.fn.has 'nvim-0.10' == 1 then
  -- scroll virtual lines when wrapping is on rather than jumping a big
  -- block
  vim.o.smoothscroll = true

  -- Enable tree-sitter folding
  vim.o.foldmethod = 'expr'
  -- vim.o.foldexpr = 'v:lua.vim.lsp.foldexpr()'
  vim.o.foldlevel = 99
  vim.o.foldtext = ''

  -- Was getting nofold errors on session restore even when I didn't create
  -- any, so leave foldlevelstart unset.
  -- vim.o.foldlevelstart = 99

  -- Show fold indicators in the gutter. 'auto:1' = width auto-sizes up to
  -- fold level 1. Required even with a custom statuscolumn: the %C item
  -- only draws when 'foldcolumn' is non-zero.
  vim.o.foldcolumn = '0'
end

-- Set default tab options (but they should be overridden by guess-indent)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.shiftround = true
vim.o.smartindent = true

-- Recommended session options from auto-sessions
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- signcolumn on right exploration. ultimately, i like the numbers closers than the signs
-- vim.o.statuscolumn = "%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '' : v:lnum) : ''} %s"
vim.o.numberwidth = 3
-- %C draws the fold column (needs 'foldcolumn' set above to have width);
-- %l is the line number, %s the sign column (gitsigns/diagnostics).
vim.o.statuscolumn = '%l %s'

vim.o.laststatus = 3

-- Enable wrapping of long lines and linebreak on words
vim.o.wrap = false
vim.o.linebreak = true

-- Preserve view when using jumplist and remove unloaded buffers (experimental)
vim.o.jumpoptions = 'view,clean'

-- Don't always keep splits the same size.
-- Commenting out while I try out setting winfixwidth/winfixheight
-- vim.o.equalalways = false

-- Set better diffopt defaults
-- https://www.reddit.com/r/neovim/comments/1myfvla/comment/nad22ts/
if vim.fn.has 'nvim-0.12' == 1 then
  vim.o.diffopt = 'internal,filler,closeoff,algorithm:patience,indent-heuristic,inline:char,linematch:40'
elseif vim.fn.has 'nvim-0.11' == 1 then
  vim.o.diffopt = 'internal,filler,closeoff,algorithm:patience,indent-heuristic,linematch:40'
end

-- Add ** to the path for expansion in :find
vim.opt.path:append '**'

require('vim._core.ui2').enable()

vim.o.winborder = 'rounded'

vim.opt.swapfile = false

-- Diagnostics
vim.diagnostic.config {
  jump = {
    float = true,
  },
  severity_sort = true,
  signs = {
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
    },
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '',
      [vim.diagnostic.severity.INFO] = '',
    },
  },
  underline = false,
  virtual_text = true,
}

-- vim: ts=2 sts=2 sw=2 et
