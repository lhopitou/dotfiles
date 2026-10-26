return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'igorlfs/nvim-dap-view', cmd = 'DapViewToggle' },
    },
    keys = {
      { '<leader>dd', function() require('dap').continue() end, desc = 'Start/continue debug session' },
      { '<leader>dq', function() require('dap').terminate() end, desc = 'Terminate debug session' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      { '<leader>dj', function() require('dap').step_over() end, desc = 'Step over function' },
      { '<leader>dl', function() require('dap').step_into { askForTargets = true } end, desc = 'Step into function' },
      { '<leader>dh', function() require('dap').step_out() end, desc = 'Step out of function' },
      { '<leader>dk', function() require('dap').step_back() end, desc = 'Step back' },
      { '<leader>dv', '<cmd>DapViewToggle<cr>', desc = 'DAP View' },
    },
    opts_extend = { 'adapters', 'configurations' },
    config = function(_, opts)
      local dap = require 'dap'
      local dap_view = require 'dap-view'
      for k, v in pairs(opts) do
        dap[k] = v or {}
      end
      dap.listeners.after.event_initialized.dapview_config = function() dap_view.open() end
      dap.listeners.before.event_terminated.dapview_config = function() dap_view.close() end
      dap.listeners.before.event_exited.dapview_config = function() dap_view.close() end
    end,
  },
}
