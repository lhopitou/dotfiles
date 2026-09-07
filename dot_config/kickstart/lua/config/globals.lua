-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)

if not vim.g.man_pager then
  vim.g.mapleader = ' '
  vim.g.maplocalleader = '\\'
end

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
