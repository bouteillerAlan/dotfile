local lazypath  = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require("config.options").setup()
-- Register before Treesitter emits TSUpdate during startup.
require("config.treesitter_progress").setup()

require("lazy").setup({
  spec = { { import = "plugins" } },
  checker = { enabled = true, minimum_release_age = "14d" },
})

-- basic
require("config.lsp").setup()
require("config.treesitter").setup()
require("config.keymaps").setup()

-- overseer script
-- light yanked text
-- floating term
require("config.commands").setup()
-- auto typing for ts/js code
require("config.autotype").setup()

-- pi integration (`:SuperAi`, visual `<leader>pi` `<leader>pia`, Esc aborts)
require("config.pi_ai").setup()

-- snippet finder
require("config.snipet_finder").setup()
