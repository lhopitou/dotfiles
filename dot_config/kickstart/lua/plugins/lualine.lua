local function get_project_root()
  -- Try to get the root from active LSP clients first
  local clients = vim.lsp.get_clients { bufnr = 0 }
  for _, client in ipairs(clients) do
    if client.root_dir then
      -- Returns only the folder name (e.g., "my-project")
      return vim.fs.basename(client.root_dir)
    end
  end

  -- Fallback: Detect root using native Neovim file system markers
  local fallback_root = vim.fs.root(0, { '.git', 'package.json', 'Cargo.toml', 'go.mod' })
  if fallback_root then return vim.fs.basename(fallback_root) end

  -- Ultimate fallback: Return current working directory folder name
  return vim.fs.basename(vim.uv.cwd())
end

return {
  -- {
  --   'nvim-lualine/lualine.nvim',
  --   event = 'VeryLazy',
  --   init = function()
  --     if vim.fn.argc(-1) > 0 then
  --       -- set an empty statusline till lualine loads
  --       vim.o.statusline = ' '
  --     else
  --       -- hide the statusline on the starter page
  --       vim.o.laststatus = 0
  --     end
  --   end,
  --   opts = {
  --     options = {
  --       globalstatus = true,
  --       disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' } },
  --     },
  --     sections = {
  --       lualine_a = { 'mode' },
  --       lualine_b = { { get_project_root }, 'branch', 'diff' },
  --       lualine_c = {
  --         {
  --           'tabs',
  --           cond = function() return vim.fn.tabpagenr '$' > 1 end,
  --         },
  --         'buffers',
  --       },
  --       lualine_x = {},
  --       lualine_y = { 'diagnostics', 'lsp_status', 'filetype' },
  --       lualine_z = { 'progress', 'location' },
  --     },
  --   },
  -- },
}
