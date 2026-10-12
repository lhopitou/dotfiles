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

require('jdtls').start_or_attach {
  cmd = cmd,
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
    },
  },
}
