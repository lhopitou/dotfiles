local function get_jdtls_cache_dir() return vim.fn.stdpath 'cache' .. '/jdtls' end

local function get_jdtls_workspace_dir() return get_jdtls_cache_dir() .. '/workspace' end

local function get_jdtls_jvm_args()
  local env = os.getenv 'JDTLS_JVM_ARGS'
  local args = {}
  for a in string.gmatch((env or ''), '%S+') do
    local arg = string.format('--jvm-arg=%s', a)
    table.insert(args, arg)
  end
  return unpack(args)
end

local root_markers1 = {
  -- Multi-module projects
  'mvnw', -- Maven
  'gradlew', -- Gradle
  'settings.gradle', -- Gradle
  'settings.gradle.kts', -- Gradle
}
local root_markers2 = {
  -- Single-module projects
  'build.xml', -- Ant
  'pom.xml', -- Maven
  'build.gradle', -- Gradle
  'build.gradle.kts', -- Gradle
}

local workspace_dir = get_jdtls_workspace_dir()
local root_dir = vim.fs.root(0, root_markers1) or vim.fs.root(0, root_markers2) or vim.fs.root(0, '.git')
local data_dir = workspace_dir
if root_dir then data_dir = data_dir .. '/' .. vim.fn.fnamemodify(root_dir, ':p:h:t') end

local cmd = {
  'jdtls',
  '--jvm-arg=-javaagent:' .. vim.fn.expand '$MASON/share/jdtls/lombok.jar',
  '-data',
  data_dir,
  get_jdtls_jvm_args(),
}

local bundles = {
  vim.fn.glob(vim.fn.expand '$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar'),
}
vim.list_extend(bundles, require('spring_boot').java_extensions())

local jdtls_java_home = vim.fn.has_key(vim.fn.environ(), 'SDKMAN_DIR') and vim.fn.expand '$SDKMAN_DIR/candidates/java/current' or vim.fn.expand '$JAVA_HOME'

require('jdtls').start_or_attach {
  cmd = cmd,
  cmd_env = { JAVA_HOME = jdtls_java_home },
  root_dir = root_dir,
  settings = {
    java = {
      eclipse = { downloadSources = true },
      configuration = { updateBuildConfiguration = 'interactive' },
      maven = { downloadSources = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      inlayHints = { parameterNames = { enabled = 'all' } },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      autobuild = { enabled = false },
    },
  },
  init_options = {
    bundles = bundles,
  },
}

require('nvim-mybatis').setup()
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('Java_lsp_attach', { clear = true }),
  callback = function()
    vim.keymap.set('n', 'gd', function()
      local utils = require 'nvim-mybatis.utils'
      local bufnr = vim.api.nvim_get_current_buf()
      if utils.is_mybatis_file(bufnr) then
        return '<cmd>MybatisJump<cr>'
      else
        return '<cmd>FzfLua lsp_definitions     jump1=true ignore_current_line=true<cr>'
      end
    end, { expr = true, desc = 'Goto Definition' })
  end,
})
