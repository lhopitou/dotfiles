local map = vim.keymap.set

-- requires mini.animate
local animate_scroll = function(before, after, mode)
  local execute = function(action)
    if type(action) == 'function' then
      action()
    elseif type(action) == 'string' then
      vim.api.nvim_feedkeys(vim.keycode(action), mode or 'n', false)
    end
  end
  local animate = require 'mini.animate'
  execute(before)
  animate.execute_after('scroll', function() execute(after) end)
end

map({ 'n', 'i', 'x', 's' }, '<c-s>', '<esc><cmd>w<cr>', { desc = 'Write buffer' })

-- Movement
map({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
map({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ 'n', 'x' }, '<c-u>', function() animate_scroll('<c-u>', 'zz') end)
map({ 'n', 'x' }, '<c-d>', function() animate_scroll('<c-d>', 'zz') end)
map('x', 'J', "<cmd>m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('x', 'K', "<cmd>m '<-2<CR>gv=gv", { desc = 'Move selection up' })

map({ 'n', 'x' }, 'n', function()
  local keys = vim.v.searchforward == 1 and 'n' or 'N'
  animate_scroll(keys, 'zvzz')
end, { desc = 'Next search result' })
map({ 'n', 'x' }, 'N', function()
  local keys = vim.v.searchforward == 1 and 'N' or 'n'
  animate_scroll(keys, 'zvzz')
end, { desc = 'Previous search result' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Yank and paste
map('v', 'y', 'myy`y', { desc = 'Yank and keep cursor position' })
map('x', 'p', 'P', { desc = 'Paste over selection (preserve register)' })
map('x', 'P', 'p', { desc = 'Paste over selection (overwrite register)' })
map('n', '<space>y', '<cmd>%yank<CR>', { desc = 'Yank whole buffer' })

-- Buffer management
map('n', 'H', '<cmd>bp<cr>', { desc = 'Go to previous buffer' })
map('n', 'L', '<cmd>bn<cr>', { desc = 'Go to next buffer' })
map('n', '<leader>bd', function() require('snacks').bufdelete() end, { desc = 'Delete current buffer' })
map('n', '<leader>ba', function() require('snacks').bufdelete.all() end, { desc = 'Delete all buffers' })
map('n', '<leader>bi', function() require('snacks').bufdelete.invisible() end, { desc = 'Delete invisible buffers' })
map('n', '<leader>bo', function() require('snacks').bufdelete.other() end, { desc = 'Delete all other buffers' })
map('n', '<leader>bn', ':enew<cr>', { desc = 'Create new buffer' })

-- Window management
map('n', '<c-h>', '<c-w>h', { desc = 'Go to the left window' })
map('n', '<c-j>', '<c-w>j', { desc = 'Go to the down window' })
map('n', '<c-k>', '<c-w>k', { desc = 'Go to the up window' })
map('n', '<c-l>', '<c-w>l', { desc = 'Go to the right window' })
map('n', '<leader>wo', '<c-w>o', { desc = 'Close all other windows' })
map('n', '<leader>wq', '<c-w>q', { desc = 'Quit a window' })
map('n', '<leader>-', '<c-w>s', { desc = 'Split window horizontally' })
map('n', '<leader>\\', '<c-w>v', { desc = 'Split window vertically' })

-- LSP
map('n', '<leader>ld', ':lsp disable ', { desc = 'Disable LSP' })
map('n', '<leader>lr', ':lsp restart ', { desc = 'Restart LSP' })
map('n', '<leader>lR', '<cmd>lsp restart<cr>', { desc = 'Restart all LSP' })
map('n', '<leader>li', '<cmd>checkhealth vim.lsp<cr>', { desc = 'LSP Info' })
map('n', '<leader>lm', '<cmd>Mason<cr>', { desc = 'Mason' })

-- Diagnostics
local jump_open_diagnostic = function(count, severity)
  local jump = function() vim.diagnostic.jump { count = count, severity = severity } end
  local open_float = function()
    vim.defer_fn(function() vim.diagnostic.open_float() end, 100)
  end
  animate_scroll(jump, open_float)
end
map('n', ']d', function() jump_open_diagnostic(1) end, { desc = 'Jump to next diagnostic' })
map('n', '[d', function() jump_open_diagnostic(-1) end, { desc = 'Jump to previous diagnostic' })
map('n', ']e', function() jump_open_diagnostic(1, vim.diagnostic.severity.ERROR) end, { desc = 'Jump to next error' })
map('n', '[e', function() jump_open_diagnostic(-1, vim.diagnostic.severity.ERROR) end, { desc = 'Jump to previous error' })
map('n', ']w', function() jump_open_diagnostic(1, vim.diagnostic.severity.WARN) end, { desc = 'Jump to next warning' })
map('n', '[w', function() jump_open_diagnostic(-1, vim.diagnostic.severity.WARN) end, { desc = 'Jump to previous warning' })

-- Quickfix
map('n', '<space>qq', ':copen<cr>', { desc = 'Open quckfix list' })
map('n', '<space>ql', ':lopen<cr>', { desc = 'Open location list' })
map('n', '<leader>qd', vim.diagnostic.setloclist, { desc = 'Send local diagnostics to location list' })
map('n', '<leader>qD', vim.diagnostic.setqflist, { desc = 'Send workspace diagnostics to quickfix' })

map('n', '<space>p', '<cmd>Lazy<cr>', { desc = 'Package manager' })

-- Quit
map('n', '<leader>za', ':wqa<cr>', { desc = 'Quit Neovim' })
map('n', '<leader>zz', 'ZZ', { desc = 'Save and quit' })
map('n', '<leader>zq', 'ZQ', { desc = 'Quit without save' })
map('n', '<leader>zr', 'ZR', { desc = 'Restart' })
