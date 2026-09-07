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

  local OSIcon = {
    init = function(self)
      local get_os = function()
        local f = io.open('/etc/os-release', 'r')
        if not f then return 'Unknown' end
        local content = f:read '*a'
        f:close()
        for line in content:gmatch '[^\r\n]+' do
          if line:match '^ID=' then return line:gsub('ID=', ''):gsub('"', '') end
        end
        return 'Unknown'
      end
      self.os = get_os()
      self.icon, self.hl = require('mini.icons').get('os', self.os)
    end,
    provider = function(self) return self.icon end,
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
        n = 'N',
        no = 'N?',
        nov = 'N?',
        noV = 'N?',
        ['no\22'] = 'N?',
        niI = 'Ni',
        niR = 'Nr',
        niV = 'Nv',
        nt = 'Nt',
        ntT = 'Nt',
        v = 'V',
        vs = 'Vs',
        V = 'V_',
        Vs = 'Vs',
        ['\22'] = '^V',
        ['\22s'] = '^V',
        s = 'S',
        S = 'S_',
        ['\19'] = '^S',
        i = 'I',
        ic = 'Ic',
        ix = 'Ix',
        R = 'R',
        Rc = 'Rc',
        Rx = 'Rx',
        Rv = 'Rv',
        Rvc = 'Rv',
        Rvx = 'Rv',
        c = 'C',
        cv = 'Ex',
        r = '...',
        rm = 'M',
        ['r?'] = '?',
        ['!'] = '!',
        t = 'T',
      },
      mode_colors = {
        n = 'red',
        i = 'green',
        v = 'cyan',
        V = 'cyan',
        ['\22'] = 'cyan',
        c = 'orange',
        s = 'purple',
        S = 'purple',
        ['\19'] = 'purple',
        R = 'orange',
        r = 'orange',
        ['!'] = 'red',
        t = 'red',
      },
    },
    -- We can now access the value of mode() that, by now, would have been
    -- computed by `init()` and use it to index our strings dictionary.
    -- note how `static` fields become just regular attributes once the
    -- component is instantiated.
    -- To be extra meticulous, we can also add some vim statusline syntax to
    -- control the padding and make sure our string is always at least 2
    -- characters long. Plus a nice Icon.
    provider = function(self) return ' %2(' .. self.mode_names[self.mode] .. '%)' end,
    -- Same goes for the highlight. Now the foreground will change according to the current mode.
    hl = function(self)
      local mode = self.mode:sub(1, 1) -- get only the first mode character
      return { fg = self.mode_colors[mode], bold = true }
    end,
    -- Re-evaluate the component only on ModeChanged event!
    -- Also allows the statusline to be re-evaluated when entering operator-pending mode
    update = {
      'ModeChanged',
      pattern = '*:*',
      callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end),
    },
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
    init = function(self) self.root_dir = get_root_dir() end,
    provider = function(self) return vim.fn.fnamemodify(self.root_dir, ':~') end,
    update = {
      'BufEnter',
      'DirChanged',
      'LspAttach',
      'LspDetach',
      callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end),
    },
  }

  local FileName = {
    init = function(self)
      self.root_dir = get_root_dir()
      self.filename = vim.api.nvim_buf_get_name(0)
      local icon, hl = MiniIcons.get('file', self.filename)
      self.icon = icon
      self.bg = utils.get_highlight(tostring(hl)).fg
      self.modified = vim.bo.modified
      self.readonly = not vim.bo.modifiable or vim.bo.readonly
      if self.modified then
        self.pill = { bg = bit.bxor(self.bg, 0xFFFFFF), fg = 'fg' }
      elseif self.readonly then
        self.pill = { bg = 'cmt', fg = 'fg' }
      else
        self.pill = { bg = self.bg, fg = 'bg' }
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
      hl = function(self) return { bg = self.bg, fg = 'bg' } end,
      Space,
      {
        provider = function(self)
          if self.filename == '' then return '[No Name]' end
          return string.gsub(self.filename, '^' .. vim.pesc(self.root_dir), '@')
        end,
      },
    },
    { DelimiterR, hl = function(self) return { fg = self.bg } end },
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

  local LSPActive = {
    condition = conditions.lsp_attached,
    update = { 'LspAttach', 'LspDetach' },
    utils.surround({ DelimiterL.provider, DelimiterR.provider }, 'str', {
      hl = { fg = 'bg' },
      { provider = ' ' },
      {
        provider = function()
          local names = {}
          for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
            table.insert(names, server.name)
          end
          return table.concat(names, ' ')
        end,
      },
    }),
  }

  local FormatterActive = {
    update = { 'BufEnter', 'BufWritePost' },
    init = function(self)
      local conform = require 'conform'
      local formatters = conform.list_formatters_to_run(0)
      self.formatters = {}
      for _, formatter in ipairs(formatters) do
        table.insert(self.formatters, formatter.name)
      end
    end,
    {
      condition = function(self) return #self.formatters > 0 end,
      utils.surround({ DelimiterL.provider, DelimiterR.provider }, 'str', {
        provider = function(self) return #self.formatters > 0 and '󰉁 ' .. table.concat(self.formatters, '->') end or '',
        hl = { fg = 'bg' },
      }),
    },
  }

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
    update = { 'DiagnosticChanged', 'BufEnter' },
    { DelimiterL, hl = function(self) return { fg = self.active[1].hl.bg } end },
    { provider = function(self) return self.components:eval() end },
    { DelimiterR, hl = function(self) return { fg = self.active[#self.active].hl.bg } end },
  }

  local Git = {
    condition = conditions.is_git_repo,
    init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
    { -- git branch name
      provider = function(self) return ' ' .. self.status_dict.head end,
      hl = { bold = true },
    },
  }

  local LastYanked = {
    update = { 'TextYankPost', 'ModeChanged' },
    init = function(self)
      local content = vim.fn.getreginfo('+').regcontents
      if not content or #content == 0 then
        self.count = 0
        self.yanked = ''
        return
      end
      self.count = #content
      self.yanked = content[1]:gsub('^%s*(.-)%s*$', '%1')
    end,
    provider = function(self)
      if self.count == 0 or self.yanked == '' then return '' end
      local max_len = 12
      local text = vim.fn.strcharpart(self.yanked, 0, max_len)
      if vim.fn.strchars(self.yanked) > max_len then text = text .. '...' end

      local line_text = self.count == 1 and '[1 line] ' or '[' .. self.count .. ' lines] '
      return line_text .. text
    end,
  }

  -- Full nerd (with icon colors and clickable elements)!
  -- works in multi window, but does not support flexible components (yet ...)
  local Navic = {
    condition = function() return require('nvim-navic').is_available() end,
    static = {
      -- create a type highlight map
      type_hl = {
        File = 'Directory',
        Module = '@include',
        Namespace = '@namespace',
        Package = '@include',
        Class = '@structure',
        Method = '@method',
        Property = '@property',
        Field = '@field',
        Constructor = '@constructor',
        Enum = '@field',
        Interface = '@type',
        Function = '@function',
        Variable = '@variable',
        Constant = '@constant',
        String = '@string',
        Number = '@number',
        Boolean = '@boolean',
        Array = '@field',
        Object = '@type',
        Key = '@keyword',
        Null = '@comment',
        EnumMember = '@field',
        Struct = '@structure',
        Event = '@keyword',
        Operator = '@operator',
        TypeParameter = '@type',
      },
      -- bit operation dark magic, see below...
      enc = function(line, col, winnr) return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr) end,
      -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
      dec = function(c)
        local line = bit.rshift(c, 16)
        local col = bit.band(bit.rshift(c, 6), 1023)
        local winnr = bit.band(c, 63)
        return line, col, winnr
      end,
      get_hl = function(type_hl) return utils.get_highlight(type_hl).fg end,
    },
    init = function(self)
      local data = require('nvim-navic').get_data() or {}
      local children = {}
      -- create a child for each level
      for i, d in ipairs(data) do
        -- encode line and column numbers into a single integer
        local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
        local child = {
          hl = { bg = self.get_hl(self.type_hl[d.type]), fg = 'bg' },
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

        local curr_hl = self.get_hl(self.type_hl[d.type])
        local next_hl = i < #data and self.get_hl(self.type_hl[data[i + 1].type]) or nil
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
    -- update = { 'CursorMoved', 'CursorHold' },
  }

  local StatusLine = {
    hl = { bg = 'bg', fg = 'fg' },
    Space,
    ViMode,
    Space,
    RootDir,
    Space,
    Git,
    Space,
    Diagnostics,
    Align,
    FileName,
    Space,
    Navic,
    Align,
    LastYanked,
    Space,
    LSPActive,
    Space,
    FormatterActive,
    Space,
    Ruler,
  }

  return {
    statusline = StatusLine,
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

  local mode_normal = lualine_mode 'normal'
  local mode_insert = lualine_mode 'insert'
  local mode_visual = lualine_mode 'visual'
  local mode_command = lualine_mode 'command'
  local mode_replace = lualine_mode 'replace'
  local mode_inactive = lualine_mode 'inactive'
  local mode_terminal = lualine_mode 'terminal'

  local colors = {
    bg = Normal.bg,
    fg = Normal.fg,
    cmt = Comment.fg,
    str = String.fg,
    func = Function.fg,
    error = error.fg,
    warn = warn.fg,
    hint = hint.fg,
    info = info.fg,
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
  opts = Opts,
  config = function(_, opts)
    local heirline = require 'heirline'
    heirline.load_colors(Colors())
    heirline.setup(opts)
  end,
}
