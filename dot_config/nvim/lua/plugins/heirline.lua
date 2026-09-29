local get_root_dir = function()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local lsp_root
  if not vim.tbl_isempty(clients) then lsp_root = clients[1].root_dir end
  return lsp_root or vim.fs.root(0, '.git') or vim.fn.getcwd()
end

local lualine_mode = function(mode, fallback)
  if not vim.g.colors_name then return fallback end
  local lualine_avail, lualine = pcall(require, 'lualine.themes.' .. vim.g.colors_name)
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == 'table' and lualine_opts.a.bg or fallback
end

local Opts = function()
  local conditions = require 'heirline.conditions'
  local utils = require 'heirline.utils'
  local MiniIcons = require 'mini.icons'

  local Align = {
    provider = '%=',
  }

  local Space = {
    provider = ' ',
  }

  local DelimiterL = {
    provider = '',
  }

  local DelimiterR = {
    provider = '',
  }

  local ViMode = {
    -- get vim current mode, this information will be required by the provider
    -- and the highlight functions, so we compute it only once per component
    -- evaluation and store it as a component attribute
    init = function(self)
      self.mode = vim.fn.mode(1) -- :h mode()
    end,
    -- Now we define some dictionaries to map the output of mode() to the
    -- corresponding string and color. We can put these into `static` to compute
    -- them at initialisation time.
    static = {
      mode_names = { -- change the strings if you like it vvvvverbose!
        n = 'Normal',
        no = 'O-pending',
        nov = 'O-pending',
        noV = 'O-pending',
        ['no\22'] = 'O-pending',
        niI = 'Normal',
        niR = 'Normal',
        niV = 'Normal',
        nt = 'Normal',
        ntT = 'Normal',
        v = 'Visual',
        vs = 'Visual',
        V = 'V-line',
        Vs = 'V-line',
        ['\22'] = 'V-block',
        ['\22s'] = 'V-block',
        s = 'Select',
        S = 'S-line',
        ['\19'] = 'S-block',
        i = 'Insert',
        ic = 'Insert',
        ix = 'Insert',
        R = 'Replace',
        Rc = 'Replace',
        Rx = 'Replace',
        Rv = 'V-replace',
        Rvc = 'V-replace',
        Rvx = 'V-replace',
        c = 'Command',
        cr = 'Command',
        cv = 'Ex',
        cvr = 'Ex',
        r = 'Replace',
        rm = 'More',
        ['r?'] = 'Confirm',
        ['!'] = 'Shell',
        t = 'Terminal',
      },

      mode_colors = {
        n = 'normal',
        i = 'insert',
        v = 'visual',
        V = 'visual',
        ['\22'] = 'visual',
        c = 'command',
        s = 'visual',
        S = 'visual',
        ['\19'] = 'visual',
        R = 'replace',
        r = 'replace',
        ['!'] = 'terminal',
        t = 'terminal',
      },
    },
    hl = { fg = 'bg', bold = true },
    utils.surround({ DelimiterL.provider, DelimiterR.provider }, function(self)
      local mode = self.mode:sub(1, 1) -- get only the first mode character
      return self.mode_colors[mode]
    end, { provider = function(self) return ' ' .. string.upper(self.mode_names[self.mode]) end }),
  }

  local Ruler = {
    static = {
      sbar = { '█', '▇', '▆', '▅', '▄', '▃', '▂', '▁', ' ' },
    },
    init = function(self)
      self.row, self.col = unpack(vim.api.nvim_win_get_cursor(0))
      local lines = vim.api.nvim_buf_line_count(0)
      self.i = math.floor((self.row - 1) / lines * #self.sbar) + 1
    end,
    utils.surround({ DelimiterL.provider, DelimiterR.provider }, 'fg', {
      {
        provider = function(self) return self.sbar[self.i] end,
        hl = { bg = 'cmt' },
      },
      {
        hl = { bg = 'cmt' },
        provider = function(self)
          local text = self.row .. ':' .. self.col + 1
          local length = #text
          local min_length = 8
          if length >= min_length then return text end
          local padding = min_length - length
          local paddingR = math.floor(padding / 2)
          local paddingL = padding - paddingR
          return string.rep(' ', paddingL) .. text .. string.rep(' ', paddingR)
        end,
      },
      {
        provider = function(self) return self.sbar[#self.sbar - self.i + 1] end,
        hl = { bg = 'cmt' },
      },
    }),
  }

  local RootDir = {
    init = function(self)
      self.root_dir = get_root_dir()
      local _, hl = MiniIcons.get('directory', '.git')
      self.dir_hl = utils.get_highlight(tostring(hl)).fg
    end,
    hl = { fg = 'bg', bold = true },
    utils.surround(
      { DelimiterL.provider, DelimiterR.provider },
      function(self) return self.dir_hl end,
      { provider = function(self) return vim.fn.fnamemodify(self.root_dir, ':~') end }
    ),
    update = {
      'BufEnter',
      'DirChanged',
      'LspAttach',
      'LspDetach',
      callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end),
    },
  }

  local NormalFileName = {
    condition = function() return not vim.wo.diff end,
    provider = function(self)
      if self.filename == '' then return '[No Name]' end
      return string.gsub(self.filename, '^' .. vim.pesc(self.root_dir), '@')
    end,
  }

  local DiffviewName = {
    condition = function() return vim.wo.diff end,
    static = {
      -- TODO: git name-rev --name-only {hash}
      diffview_meta = function()
        local view = require('diffview.lib').get_current_view()
        if not view then return '[No Name]' end

        local layout = view.cur_layout
        local kind = view.cur_entry.kind
        local winid = vim.api.nvim_get_current_win()

        if kind == 'working' then
          for _, sym in ipairs { 'a', 'b' } do
            local w = layout[sym]
            if w and w.id == winid then return {
              label = ({ a = 'base', b = 'working' })[sym],
              path = w.file.path,
            } end
          end
        elseif kind == 'staged' then
          for _, sym in ipairs { 'a', 'b' } do
            local w = layout[sym]
            if w and w.id == winid then return {
              label = ({ a = 'base', b = 'staged' })[sym],
              path = w.file.path,
            } end
          end
        else
          if kind == 'conflicting' then
            for _, sym in ipairs { 'a', 'b', 'c', 'd' } do
              local w = layout[sym]
              if w and w.id == winid then
                return {
                  label = ({ a = 'ours', b = 'local', c = 'theirs', d = 'base' })[sym],
                  stage = w.file.rev and w.file.rev.stage, -- 2=ours, 3=theirs, 1=base (nil for local)
                  path = w.file.path,
                }
              end
            end
          else
            return '[No Name]'
          end
        end
        -- vim.print(view)
        -- if not (view and view.cur_entry and view.cur_entry.kind == 'conflicting') then return end
        -- local layout = view.cur_layout
        -- local winid = vim.api.nvim_get_current_win()
        -- for _, sym in ipairs { 'a', 'b', 'c', 'd' } do
        --   local w = layout[sym]
        --   if w and w.id == winid then
        --     return {
        --       slot = sym, -- "a"|"b"|"c"|"d"
        --       label = ({ a = 'ours', b = 'local', c = 'theirs', d = 'base' })[sym],
        --       stage = w.file.rev and w.file.rev.stage, -- 2=ours, 3=theirs, 1=base (nil for local)
        --       path = w.file.path,
        --       ctx = view.merge_ctx, -- full hashes + ref_names per side
        --     }
        --   end
        -- end
      end,
    },
    provider = function(self)
      local meta = self.diffview_meta()
      local stage_str = meta.stage and '[' .. meta.stage .. ']' or ''
      return '@/' .. meta.path .. ' (' .. string.upper(meta.label) .. stage_str .. ')'
    end,
  }

  local FileName = {
    init = function(self)
      self.root_dir = get_root_dir()
      self.modified = vim.bo.modified
      self.readonly = not vim.bo.modifiable or vim.bo.readonly
      if self.modified then
        self.pill = { bg = bit.bxor(self.file_hl, 0xFFFFFF), fg = 'fg' }
      elseif self.readonly then
        self.pill = { bg = 'cmt', fg = 'fg' }
      else
        self.pill = { bg = self.file_hl, fg = 'bg' }
      end
    end,
    { DelimiterL, hl = function(self) return { fg = self.pill.bg } end },
    {
      hl = function(self) return self.pill end,
      {
        provider = function(self) return self.icon end,
      },
      { Space, condition = function(self) return self.modified or self.readonly end },
    },
    {
      hl = function(self) return { bg = self.file_hl, fg = 'bg' } end,
      Space,
      NormalFileName,
      DiffviewName,
    },
    { DelimiterR, hl = function(self) return { fg = self.file_hl } end },
    update = {
      'BufEnter',
      'BufFilePost',
      'BufModifiedSet',
      'DirChanged',
      'LspAttach',
      'LspDetach',
      callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end),
    },
  }

  local FileType = {
    update = { 'BufEnter', 'FileType' },
    init = function(self)
      self.ft = vim.bo.filetype ~= '' and vim.bo.filetype or 'new'
      self.ft_icon = MiniIcons.get('filetype', self.ft)
    end,
    {
      hl = function(self) return { bg = self.file_hl, fg = 'bg' } end,
      { provider = function(self) return self.ft_icon .. ' ' .. string.upper(self.ft) end },
    },
    -- utils.surround({ DelimiterL.provider, DelimiterR.provider }, function(self) return self.file_hl end, {
    --   hl = { fg = 'bg' },
    --   { provider = function(self) return self.ft_icon .. ' ' .. string.upper(self.ft) end },
    -- }),
  }

  local LSPActive = {
    condition = conditions.lsp_attached,
    static = {
      lsp_work_by_client_id = {},
      loading = false,
    },
    update = {
      'BufEnter',
      'LspAttach',
      'LspDetach',
      'LspProgress',
      callback = function(component, args)
        if args.event ~= 'LspProgress' then
          vim.schedule(function() vim.cmd 'redrawstatus' end)
          return
        end

        local kind = args.data.params.value.kind
        local client_id = args.data.client_id
        local work = component.lsp_work_by_client_id[client_id] or 0
        local work_change = kind == 'begin' and 1 or (kind == 'end' and -1 or 0)
        local was_loading = component.loading
        component.lsp_work_by_client_id[client_id] = math.max(work + work_change, 0)
        component.loading = vim.iter(component.lsp_work_by_client_id):any(function(v) return v > 0 end)
        if component.loading ~= was_loading then vim.schedule(function() vim.cmd 'redrawstatus' end) end
      end,
    },
    {
      hl = function(self) return { bg = self.file_hl, fg = 'bg' } end,
      { provider = function(self) return self.loading and '' or '' end },
      Space,
      {
        provider = function()
          local names = {}
          for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
            table.insert(names, server.name)
          end
          return table.concat(names, ' ')
        end,
      },
      { provider = '  ' },
      -- { provider = ' 󰜋 ' },
    },
    -- utils.surround({ DelimiterL.provider, DelimiterR.provider }, function(self) return self.file_hl end, {
    --   hl = { fg = 'bg' },
    --   { provider = function(self) return self.loading and '' or '' end },
    --   Space,
    --   {
    --     provider = function()
    --       local names = {}
    --       for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
    --         table.insert(names, server.name)
    --       end
    --       return table.concat(names, ' ')
    --     end,
    --   },
    -- }),
  }

  local FormatterActive = {
    update = { 'BufEnter', 'BufWritePost', 'LspAttach' },
    init = function(self)
      local conform = require 'conform'
      local formatters, lsp = conform.list_formatters_to_run(0)
      self.formatters = {}
      for _, formatter in ipairs(formatters) do
        table.insert(self.formatters, formatter.name)
      end
      if #self.formatters == 0 and lsp then table.insert(self.formatters, 'LSP') end
    end,
    {
      condition = function(self) return #self.formatters > 0 end,
      hl = function(self) return { bg = self.file_hl, fg = 'bg' } end,
      {
        provider = function(self) return #self.formatters > 0 and ' ' .. table.concat(self.formatters, ' 󰅂 ') end or '',
      },
      { provider = '  ' },
      -- { provider = ' 󰜋 ' },
      -- utils.surround({ DelimiterL.provider, DelimiterR.provider }, function(self) return self.file_hl end, {
      --   provider = function(self) return #self.formatters > 0 and ' ' .. table.concat(self.formatters, '->') end or '',
      --   hl = { fg = 'bg' },
      -- }),
    },
  }

  local FileTypeBlock = utils.surround({ DelimiterL.provider, DelimiterR.provider }, function(self) return self.file_hl end, {
    FormatterActive,
    LSPActive,
    FileType,
  })

  local Diagnostics = {
    condition = conditions.has_diagnostics,
    static = {
      severities = {
        { severity = vim.diagnostic.severity.ERROR, hl = 'error' },
        { severity = vim.diagnostic.severity.WARN, hl = 'warn' },
        { severity = vim.diagnostic.severity.INFO, hl = 'info' },
        { severity = vim.diagnostic.severity.HINT, hl = 'hint' },
      },
    },
    init = function(self)
      self.active = {}
      for _, item in ipairs(self.severities) do
        local count = #vim.diagnostic.get(0, { severity = item.severity })
        if count > 0 then table.insert(self.active, { provider = ' ' .. count .. ' ', hl = { bg = item.hl, fg = 'bg' } }) end
      end
      self.components = self:new(self.active, 1)
    end,
    update = { 'DiagnosticChanged', 'BufEnter', callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end) },
    { DelimiterL, hl = function(self) return { fg = self.active[1].hl.bg } end },
    { provider = function(self) return self.components:eval() end },
    { DelimiterR, hl = function(self) return { fg = self.active[#self.active].hl.bg } end },
    Space,
  }

  local Git = {
    condition = conditions.is_git_repo,
    update = {
      'BufEnter',
      'User',
      callback = vim.schedule_wrap(function(_, args)
        if args.event == 'User' and not vim.tbl_contains({ 'GitSignsUpdate', 'GitSignsChanged' }, args.match) then return end
        vim.cmd 'redrawstatus'
      end),
    },
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict or { head = vim.b.gitsigns_head }
      local dict = self.status_dict
      if dict.added == nil and dict.changed == nil and dict.removed == nil then
        self.color = 'diff_del'
      else
        local total = (dict.added or 0) + (dict.changed or 0) + (dict.removed or 0)
        self.color = total == 0 and 'diff_change' or 'diff_add'
      end
    end,
    utils.surround({ DelimiterL.provider, DelimiterR.provider }, function(self) return self.color end, {
      hl = { fg = 'bg' },
      provider = function(self) return ' ' .. (self.status_dict.head or '') end,
    }),
  }

  -- local LastYanked = {
  --   update = { 'TextYankPost', 'ModeChanged' },
  --   init = function(self)
  --     local content = vim.fn.getreginfo('+').regcontents
  --     if not content or #content == 0 then
  --       self.count = 0
  --       self.yanked = ''
  --       return
  --     end
  --     self.count = #content
  --     self.yanked = content[1]:gsub('^%s*(.-)%s*$', '%1')
  --   end,
  --   provider = function(self)
  --     if self.count == 0 or self.yanked == '' then return '' end
  --     local max_len = 12
  --     local text = vim.fn.strcharpart(self.yanked, 0, max_len)
  --     if vim.fn.strchars(self.yanked) > max_len then text = text .. '...' end
  --
  --     local line_text = self.count == 1 and '[1 line] ' or '[' .. self.count .. ' lines] '
  --     return line_text .. text
  --   end,
  -- }

  local LastSearched = {
    init = function(self)
      local content = vim.fn.getreginfo('/').regcontents
      if not content or #content == 0 then
        self.text = nil
        return
      end
      self.text = content[1]:gsub('%%', '%%%%')
    end,
    {
      condition = function(self) return self.text ~= nil and self.text ~= '' end,
      hl = { fg = 'bg' },
      utils.surround({ DelimiterL.provider, DelimiterR.provider }, utils.get_highlight('IncSearch').bg, {
        provider = function(self) return ' ' .. self.text end,
      }),
    },
  }

  -- Full nerd (with icon colors and clickable elements)!
  -- works in multi window, but does not support flexible components (yet ...)
  local Navic = {
    condition = function() return require('nvim-navic').is_available() end,
    static = {
      -- bit operation dark magic, see below...
      enc = function(line, col, winnr) return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr) end,
      -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
      dec = function(c)
        local line = bit.rshift(c, 16)
        local col = bit.band(bit.rshift(c, 6), 1023)
        local winnr = bit.band(c, 63)
        return line, col, winnr
      end,
      get_hl = function(type, i)
        local hl = utils.get_highlight('NavicIcons' .. type).fg
        if i % 2 == 0 then hl = 0xFFFFFF - hl end
        return hl
      end,
    },
    init = function(self)
      local data = require('nvim-navic').get_data() or {}
      local children = {}
      -- create a child for each level
      for i, d in ipairs(data) do
        -- encode line and column numbers into a single integer
        local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
        local child = {
          hl = { bg = self.get_hl(d.type, i), fg = i % 2 == 0 and 'fg' or 'bg' },
          {
            provider = d.icon,
          },
          {
            -- escape `%`s (elixir) and buggy default separators
            provider = d.name:gsub('%%', '%%%%'):gsub('%s*->%s*', ''),
            on_click = {
              -- pass the encoded position through minwid
              minwid = pos,
              callback = function(_, minwid)
                -- decode
                local line, col, winnr = self.dec(minwid)
                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
              end,
              name = 'heirline_navic',
            },
          },
        }

        local curr_hl = self.get_hl(d.type, i)
        local next_hl = i < #data and self.get_hl(data[i + 1].type, i + 1) or nil
        if i == 1 then table.insert(children, {
          { DelimiterL, hl = { fg = curr_hl } },
        }) end
        table.insert(children, child)
        if i < #data then table.insert(children, {
          hl = { fg = curr_hl, bg = next_hl },
          DelimiterR,
          Space,
        }) end
        if i == #data then table.insert(children, { DelimiterR, hl = { fg = curr_hl } }) end
      end
      -- instantiate the new child, overwriting the previous one
      self.child = self:new(children, 1)
    end,
    -- evaluate the children containing navic components
    provider = function(self) return self.child:eval() end,
    update = {
      'CursorMoved',
      'User',
      callback = function(_, args)
        if args.event == 'User' and args.match == 'NavicReady' then vim.schedule(function() vim.cmd 'redrawstatus' end) end
      end,
    },
  }

  local StatusLine = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
      local icon, hl = MiniIcons.get('file', self.filename)
      self.icon = icon
      self.file_hl = utils.get_highlight(tostring(hl)).fg
    end,
    hl = { bg = 'bg', fg = 'fg' },
    ViMode,
    Space,
    RootDir,
    Space,
    Git,
    Align,
    -- FileName,
    -- Space,
    -- Navic,
    -- Align,
    LastSearched,
    Space,
    Diagnostics,
    FileTypeBlock,
    -- LSPActive,
    -- FormatterActive,
    -- FileType,
    Space,
    Ruler,
  }

  local Winbar = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
      local icon, hl = MiniIcons.get('file', self.filename)
      self.icon = icon
      self.file_hl = utils.get_highlight(tostring(hl)).fg
    end,
    hl = { bg = 'bg', fg = 'fg' },
    FileName,
    Space,
    {
      condition = function() return conditions.is_active() end,
      Navic,
    },
    Align,
  }

  return {
    statusline = StatusLine,
    winbar = Winbar,
    opts = {
      -- if the callback returns true, the winbar will be disabled for that window
      -- the args parameter corresponds to the table argument passed to autocommand callbacks. :h nvim_lua_create_autocmd()
      disable_winbar_cb = function(args)
        return conditions.buffer_matches({
          buftype = { 'nofile', 'prompt', 'quickfix' },
          filetype = { 'fzf', '^git*', '^neogit*' },
        }, args.buf)
      end,
    },
  }
end

local Colors = function()
  local utils = require 'heirline.utils'
  local get_hl = utils.get_highlight

  local Normal = get_hl 'Normal'
  local Comment = get_hl 'Comment'
  local Constant = get_hl 'Constant'
  local String = get_hl 'String'
  local Number = get_hl 'Number'
  local Function = get_hl 'Function'
  local error = get_hl 'DiagnosticError'
  local warn = get_hl 'DiagnosticWarn'
  local hint = get_hl 'DiagnosticHint'
  local info = get_hl 'DiagnosticInfo'
  local DiffAdd = get_hl 'GitSignsAdd'
  local DiffChange = get_hl 'GitSignsChange'
  local DiffDelete = get_hl 'GitSignsDelete'

  local mode_normal = lualine_mode 'normal'
  local mode_insert = lualine_mode 'insert'
  local mode_visual = lualine_mode 'visual'
  local mode_command = lualine_mode 'command'
  local mode_replace = lualine_mode 'replace'
  local mode_inactive = lualine_mode 'inactive'
  local mode_terminal = lualine_mode('terminal', mode_command)

  local colors = {
    bg = Normal.bg,
    fg = Normal.fg,
    cmt = Comment.fg,
    str = String.fg,
    func = Function.fg,
    const = Constant.fg,
    num = Number.fg,
    error = error.fg,
    warn = warn.fg,
    hint = hint.fg,
    info = info.fg,
    diff_add = DiffAdd.fg,
    diff_change = DiffChange.fg,
    diff_del = DiffDelete.fg,
    normal = mode_normal,
    insert = mode_insert,
    visual = mode_visual,
    command = mode_command,
    replace = mode_replace,
    inactive = mode_inactive,
    terminal = mode_terminal,
  }

  return colors
end

return {
  'rebelot/heirline.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-mini/mini.icons' },
  opts = Opts,
  config = function(_, opts)
    local heirline = require 'heirline'
    local utils = require 'heirline.utils'
    heirline.load_colors(Colors())
    heirline.setup(opts)
    vim.api.nvim_create_augroup('Heirline', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function() utils.on_colorscheme(Colors()) end,
      group = 'Heirline',
    })
  end,
}
