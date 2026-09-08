local function augroup(name) return vim.api.nvim_create_augroup('User_' .. name, { clear = true }) end

vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'treesitter_attach',
  callback = function(event)
    -- make sure nvim-treesitter is loaded
    local ok, nvim_treesitter = pcall(require, 'nvim-treesitter')

    -- no nvim-treesitter, maybe fresh install
    if not ok then return end

    local ft = vim.bo[event.buf].ft
    if not ft then return end
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then return end
    local parsers = require 'nvim-treesitter.parsers'
    if not parsers[lang] or not nvim_treesitter.install then return end

    nvim_treesitter.install({ lang }):await(function(err)
      if err then
        vim.notify('Treesitter install error for ft: ' .. ft .. ' err: ' .. err)
        return
      end

      pcall(vim.treesitter.start, event.buf)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end)
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup 'lsp_attach',
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    vim.lsp.inlay_hint.enable()

    local map = vim.keymap.set
    map('n', 'gd', '<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>', { desc = 'Goto Definition' })
    map('n', 'gr', '<cmd>FzfLua lsp_references      jump1=true ignore_current_line=true<cr>', { desc = 'References', nowait = true })
    map('n', 'gI', '<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>', { desc = 'Goto Implementation' })
    map('n', 'gK', '<cmd>FzfLua lsp_typedefs        jump1=true ignore_current_line=true<cr>', { desc = 'Goto Type Definition' })
    map({ 'n', 'x' }, '<leader>la', function() vim.lsp.buf.code_action() end, { desc = 'Code action' })
    map({ 'n', 'x' }, '<leader>lr', function() vim.lsp.buf.rename() end, { desc = 'Rename' })

    -- nvim-navic: the first documentSymbol response arrives asynchronously, and
    -- navic only computes its breadcrumb context on cursor events (CursorMoved /
    -- CursorHold). Without this, a freshly attached buffer shows an empty
    -- breadcrumb until the cursor moves. Poll until the symbol tree lands, then
    -- prime the context once and redraw.
    if client and client.server_capabilities.documentSymbolProvider then
      local bufnr = event.buf
      local attempts = 0
      local poll
      poll = function()
        if not vim.api.nvim_buf_is_loaded(bufnr) then return end
        local ok, lib = pcall(require, 'nvim-navic.lib')
        if ok and lib.get_tree(bufnr) then
          local win = vim.fn.bufwinid(bufnr)
          if win ~= -1 then
            lib.update_context(bufnr, vim.api.nvim_win_get_cursor(win))
            vim.cmd 'redrawstatus'
          end
        elseif attempts < 300 then -- give up after ~30s
          attempts = attempts + 1
          vim.defer_fn(poll, 100)
        end
      end
      vim.defer_fn(poll, 100)
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup 'highlight_yank',
  callback = function()
    if vim.fn.has 'nvim-0.13' == 1 then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup 'last_buf_location',
  callback = function()
    if vim.o.diff then return end
    local last_pos = vim.api.nvim_buf_get_mark(0, '"')
    local last_line = vim.api.nvim_buf_line_count(0)
    local row = last_pos[1]
    if row < 1 or row > last_line then return end
    pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'wrap_spell',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close_with_q',
  pattern = { 'gitsigns-blame', 'help', 'qf', 'grug-far', 'git' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'vertical_help',
  pattern = { 'help' },
  callback = function() vim.cmd 'wincmd L' end,
})
