-- Add the plugin's lua/ directory to the runtimepath so require() works
vim.opt.rtp:append('.')

-- Test-only dependencies. Paths come from the nix devShell / flake check;
-- fall back to a lazy.nvim install for running outside nix.
local function add_dep(env_var, name)
  local path = vim.env[env_var]
  if not path or path == '' then
    path = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', name)
  end
  if vim.fn.isdirectory(path) ~= 1 then
    error(string.format('%s not found at %s (set $%s)', name, path, env_var))
  end
  vim.opt.rtp:append(path)
end
add_dep('PLENARY_NVIM_PATH', 'plenary.nvim')
add_dep('CODECOMPANION_NVIM_PATH', 'codecompanion.nvim')

-- Disable swap files and shada for test runs
vim.o.swapfile = false
vim.o.shadafile = 'NONE'

-- Give the layout some room; headless defaults are 24x80
vim.o.lines = 40
vim.o.columns = 120

-- Silence echo/notify during tests so intentional error paths don't pollute output
vim.api.nvim_echo = function() end ---@diagnostic disable-line: duplicate-set-field
vim.notify = function() end ---@diagnostic disable-line: duplicate-set-field

require('codecompanion').setup({
  -- Any adapter works; the chat is never submitted in tests.
  interactions = { chat = { adapter = 'ollama' } },
  extensions = { ui = { enabled = true } },
  opts = { log_level = 'ERROR' },
})
