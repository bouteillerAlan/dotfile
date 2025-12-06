-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.hlsearch = true
vim.opt.clipboard:append('unnamedplus')
vim.opt.relativenumber = true
-- file indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.colorcolumn = "80"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { 'catppuccin/nvim', name = 'catppuccin', priority = 1000, config = function() vim.cmd.colorscheme 'catppuccin' end },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function() require('lualine').setup() end
    },
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      branch = 'main',
      build = ':TSUpdate',
      config = function() require'nvim-treesitter'.install { 'bash', 'rust', 'go', 'typescript', 'javascript', 'zig', 'html', 'scss', 'java', 'sql', 'lua', 'json', 'markdown', 'markdown_inline', 'python', 'query', 'regex', 'tsx', 'vim', 'yaml' } end
    },
    {
      'nvim-java/nvim-java', config = function()
        require('java').setup()
        vim.lsp.enable('jdtls')
      end,
    },
    { "neovim/nvim-lspconfig" },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install' },
    {
      'nvim-telescope/telescope.nvim',
      tag = 'v0.1.9',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        require('telescope').setup({
          defaults = {
            layout_strategy = 'vertical',
            layout_config = { height = 0.95 },
          },
        })
      end
    },
    { "tpope/vim-fugitive" },
    { "nvim-mini/mini.animate", version = "*", config = function() require("mini.animate").setup() end },
    {
      "nvim-mini/mini.hipatterns",
      version = "*",
      config = function()
        local hipatterns = require('mini.hipatterns')
        hipatterns.setup({
          highlighters = {
            -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
            fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
            hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
            todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
            note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })
      end
    },
    { 'nvim-mini/mini.icons', version = '*', config = function() require('mini.icons').setup() end },
    { 'nvim-mini/mini.pairs', version = '*', config = function() require('mini.pairs').setup() end },
    { 'nvim-mini/mini.diff', version = '*', config = function() require('mini.diff').setup({view={style='number'}}) end },
    { "mfussenegger/nvim-dap" },
    { "dstein64/vim-startuptime" },
    { "lewis6991/gitsigns.nvim", config = function() require('gitsigns').setup({current_line_blame = true}) end },
    {
      'stevearc/oil.nvim',
      opts = {},
      dependencies = { { "nvim-mini/mini.icons", opts = {} } },
      lazy = false,
      config = function() require("oil").setup(
        {
          columns={"icon"},
          delete_to_trash=true,
          view_options = { show_hidden = true },
        }
      ) end,
    },
    {
      'saghen/blink.cmp',
      dependencies = { 'rafamadriz/friendly-snippets' },
      version = '1.*',
      opts = {
        keymap = { preset = 'default' },
        appearance = {
          nerd_font_variant = 'mono'
        },
        signature = { enabled = true },
      },
    },
    {
      'dgagn/diagflow.nvim',
      opts = {}
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = "Open parent directory" })
vim.keymap.set('n', '<space>-', require("oil").toggle_float)

-- special config for lua copy pasted 
-- from https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls 
vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            'lua/?.lua',
            'lua/?/init.lua',
          },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths
            -- '${3rd}/luv/library'
          }
        }
      })
    end,
    settings = {
      Lua = {}
    },
  }
)

-- for cssls
--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("cssls", {capabilities=capabilities})
vim.lsp.config('html', {capabilities = capabilities})

-- this lsp has to be installed before hand
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("emmet_ls")
vim.lsp.enable("bashls")
vim.lsp.enable("eslint")
vim.lsp.enable("groovyls")
vim.lsp.enable("golangci_lint_ls")
vim.lsp.enable("cssls")
vim.lsp.enable("emmet_language_server")
vim.lsp.enable("html")
vim.lsp.enable("codebook")
vim.lsp.enable("svelte")

