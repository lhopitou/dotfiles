-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

local animate_center = function(keys, mode)
  local key_codes = vim.keycode(keys)
  vim.api.nvim_feedkeys(key_codes, mode, false)
  local animate = require("mini.animate")
  animate.execute_after("scroll", function()
    vim.api.nvim_feedkeys("zz", mode, false)
  end)
end

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("n", "<c-u>", function()
  animate_center("<c-u>", "n")
end, { desc = "Scroll half up" })
map("n", "<c-d>", function()
  animate_center("<c-d>", "n")
end, { desc = "Scroll half down" })
map({ "n", "x" }, "n", function()
  local keys = (vim.v.searchforward == 1 and "n" or "N") .. "zv"
  animate_center(keys, "n")
end, { desc = "Next search result" })
map({ "n", "x" }, "N", function()
  local keys = (vim.v.searchforward == 1 and "N" or "n") .. "zv"
  animate_center(keys, "n")
end, { desc = "Prev search result" })

map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Yanky Put After" })
map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Yanky Put Before" })
map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Yanky GPut After" })
map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Yanky GPut Before" })
map("n", "<c-p>", "<Plug>(YankyPreviousEntry)", { desc = "Yanky Previous Entry" })
map("n", "<c-n>", "<Plug>(YankyNextEntry)", { desc = "Yanky Next Entry" })
