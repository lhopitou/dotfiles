-- Two independent visibility toggles in oil buffers:
--   <C-h>  toggle dotfiles ("hidden")
--   <C-i>  toggle gitignored files
--   g.     toggle BOTH at once (replaces oil's built-in show-all)
-- Precedence:
--   .  plain dotfile    (e.g. .prettierignore) -> <C-h> only
--   .  plain gitignored (e.g. node_modules/)   -> <C-i> only
--   .  BOTH dotfile AND gitignored (e.g. .vscode, .env) -> needs BOTH
--      <C-h> AND <C-i> on to appear
--   .  neither -> always shown
-- Revealed hidden files keep oil's muted "Hidden" highlight: is_hidden_file
-- reports the *base* classification (dotfile|gitignored) so oil applies the
-- dim color, while is_always_hidden force-hides categories whose toggle is off
-- (it overrides oil's global show_hidden, which we set when any toggle is on).
local show_dotfiles = false
local show_gitignored = false
local git_status -- built lazily inside config(); used by is_hidden_file

-- Base classification: true for any structurally hidden file. This drives the
-- muted highlight when the file is displayed (oil renders "Hidden" when
-- is_hidden is true at render time). It does NOT decide visibility on its own.
local function is_hidden_file(name, bufnr)
  local dir = require('oil').get_current_dir(bufnr)
  local is_dotfile = vim.startswith(name, '.') and name ~= '..'
  if not dir then return is_dotfile end
  return is_dotfile or git_status[dir].ignored[name]
end

-- Force-hide: overrides oil's global show_hidden so a category whose toggle is
-- OFF stays hidden even when another toggle is ON (which set show_hidden=true).
local function is_always_hidden(name, bufnr)
  local dir = require('oil').get_current_dir(bufnr)
  if name == '..' then return true end
  local is_dotfile = vim.startswith(name, '.') and name ~= '..'
  -- No local directory (e.g. ssh/trash buffers): dotfiles follow <C-h>.
  if not dir then return is_dotfile and not show_dotfiles end
  local is_gitignored = git_status[dir].ignored[name]
  -- Overlap (dotfile AND gitignored): needs BOTH toggles on.
  if is_dotfile and is_gitignored then return not (show_dotfiles and show_gitignored) end
  if is_dotfile then return not show_dotfiles end
  if is_gitignored then return not show_gitignored end
  return false
end

local function apply()
  -- Mutate the three view_options oil reads at render time, then rerender.
  -- set_is_hidden_file rerenders from cache; it warns (and no-ops) on unsaved
  -- oil edits, matching oil's own toggle_hidden behavior.
  local vo = require('oil.config').view_options
  vo.is_hidden_file = is_hidden_file
  vo.is_always_hidden = is_always_hidden
  vo.show_hidden = show_dotfiles or show_gitignored
  require('oil').set_is_hidden_file(is_hidden_file)
end

local function toggle_dotfiles()
  show_dotfiles = not show_dotfiles
  apply()
end

local function toggle_gitignored()
  show_gitignored = not show_gitignored
  apply()
end

local function toggle_all()
  -- g.: toggle both categories together ("show all hidden" / hide all).
  local both_on = show_dotfiles and show_gitignored
  show_dotfiles = not both_on
  show_gitignored = not both_on
  apply()
end

return {
  'stevearc/oil.nvim',
  lazy = false,
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    keymaps = {
      ['q'] = { 'actions.close', mode = 'n' },
      ['l'] = 'actions.select',
      ['h'] = { 'actions.parent', mode = 'n' },
      ['gh'] = { toggle_dotfiles, mode = 'n', desc = 'Toggle hidden (dotfiles)' },
      ['gi'] = { toggle_gitignored, mode = 'n', desc = 'Toggle gitignored' },
      ['g.'] = { toggle_all, mode = 'n', desc = 'Toggle all hidden' },
      ['<C-h>'] = false,
      ['<C-s>'] = false,
    },
    view_options = {
      show_hidden = false,
      is_hidden_file = is_hidden_file,
      is_always_hidden = is_always_hidden,
    },
  },
  keys = {
    { '<leader>e', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },
  dependencies = { 'nvim-mini/mini.icons' },
  config = function(_, opts)
    -- helper function to parse `git ls-files` / `git ls-tree` output
    local function parse_output(proc)
      local result = proc:wait()
      local ret = {}
      if result.code == 0 then
        for line in vim.gsplit(result.stdout, '\n', { plain = true, trimempty = true }) do
          -- Remove trailing slash (directories from --directory)
          line = line:gsub('/$', '')
          ret[line] = true
        end
      end
      return ret
    end

    -- build git status cache, lazily per directory
    local function new_git_status()
      return setmetatable({}, {
        __index = function(self, key)
          local ignore_proc = vim.system({ 'git', 'ls-files', '--ignored', '--exclude-standard', '--others', '--directory' }, {
            cwd = key,
            text = true,
          })
          local tracked_proc = vim.system({ 'git', 'ls-tree', 'HEAD', '--name-only' }, {
            cwd = key,
            text = true,
          })
          local ret = {
            ignored = parse_output(ignore_proc),
            tracked = parse_output(tracked_proc),
          }

          rawset(self, key, ret)
          return ret
        end,
      })
    end
    git_status = new_git_status()

    -- Clear git status cache on refresh
    local refresh = require('oil.actions').refresh
    local orig_refresh = refresh.callback
    refresh.callback = function(...)
      git_status = new_git_status()
      orig_refresh(...)
    end

    require('oil').setup(opts)
  end,
}
