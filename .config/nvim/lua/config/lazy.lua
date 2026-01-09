-- Config by Alan A2n Bouteiller - https://github.com/bouteillerAlan/dotfile
--
-- With this config, you got:
-- - lsp (you need to install server before hand, check the code at the bottom of this file)
-- - `autocompletion
-- - `snippet
-- - `leader ff` to search a file or a folder
-- - `leader fb` to search a buffer
-- - `leader fg` to search a string
-- - `leader fh` to search from the help tag
-- - if you do `/something`, you can navigate the result with `n` and `N` but also hit `esc` to remove the search result
-- - leader is `space`
-- - clipboard, relative number, nerdfont are activated
-- - tabs is 2
-- - a very simple but powerfull file and folder editor via `oil`, hit `-` and edit/create/delete folder and file name via the same command has any file
-- - `todo` `hack` and so on are highlighted, same for any hexa color
-- - with `blink` you got a nice personalized autocomplete UI
-- - on line git blame
-- - `leader tt` to toggle a floating terminal that conserve it's state
-- - `[d` and `]d` to navigate diagnostic
--
-- Some reminder:
-- - `:%s/string/string/g(c)` to replace all or with `c` to confirm
-- - `/` to search a pattern, then `n` or `N` to loop over it
-- - `ctrl+]` to go to definition and `ctrl+t` to return back
-- - `gg` and `G` to move top/bottom
-- - indent with `=`
-- - delete all ligne that contain "test": `:g/test/norm dd`
-- `%` on `{` (for example) go to the closing/openning one

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
vim.g.has_nerd_font = true
vim.opt.hlsearch = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.relativenumber = true
-- file indentation
vim.g.python_recommended_style = 0
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.colorcolumn = "80"
-- show trailling space
vim.opt.list = true
vim.opt.listchars = { trail = "*", nbsp = "+"}
vim.opt.undofile = true -- keep the history of undo
vim.opt.ignorecase = true -- in searching
vim.opt.scrolloff = 20

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme "catppuccin" end },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function() require("lualine").setup() end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      branch = "main",
      build = ":TSUpdate",
      config = function()
        require"nvim-treesitter".install {
          "bash",
          "rust",
          "go",
          "typescript",
          "javascript",
          "zig",
          "html",
          "scss",
          "java",
          "sql",
          "lua",
          "json",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "tsx",
          "vim",
          "yaml",
          "toml"
        }
      end
    },
    {
      "nvim-java/nvim-java", config = function()
        require("java").setup()
        vim.lsp.enable("jdtls")
      end,
    },
    { "neovim/nvim-lspconfig" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install" },
    {
      "nvim-telescope/telescope.nvim",
      tag = "v0.1.9",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-node-modules.nvim",
      },
      config = function()
        require("telescope").setup({
          defaults = {
            layout_strategy = "vertical",
            layout_config = { height = 0.95 },
          },
        })
        require("telescope").load_extension("node_modules")
      end
    },
    { "tpope/vim-fugitive" },
    { "nvim-mini/mini.animate", version = "*", config = function() require("mini.animate").setup() end },
    {
      "nvim-mini/mini.hipatterns",
      version = "*",
      config = function()
        local hipatterns = require("mini.hipatterns")
        hipatterns.setup({
          highlighters = {
            fixme = { pattern = "%f[%w]()[Ff][Ii][Xx][Mm][Ee]()%f[%W]", group = "MiniHipatternsFixme" },
            hack  = { pattern = "%f[%w]()[Hh][Aa][Cc][Kk]()%f[%W]",  group = "MiniHipatternsHack"  },
            todo  = { pattern = "%f[%w]()[Tt][Oo][Dd][Oo]()%f[%W]",  group = "MiniHipatternsTodo"  },
            note  = { pattern = "%f[%w]()[Nn][Oo][Tt][Ee]()%f[%W]",  group = "MiniHipatternsNote"  },
            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })
      end
    },
    { "nvim-mini/mini.icons", version = "*", config = function() require("mini.icons").setup() end },
    { "nvim-mini/mini.pairs", version = "*", config = function() require("mini.pairs").setup() end },
    { "nvim-mini/mini.diff", version = "*", config = function() require("mini.diff").setup({view={style="number"}}) end },
    { "mfussenegger/nvim-dap" },
    { "dstein64/vim-startuptime" },
    { "lewis6991/gitsigns.nvim", config = function() require("gitsigns").setup({current_line_blame = true}) end },
    {
      "stevearc/oil.nvim",
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
      "saghen/blink.cmp",
      dependencies = { "rafamadriz/friendly-snippets" },
      version = "1.*",
      opts = {
        keymap = { preset = "default" },
        appearance = {
          nerd_font_variant = "mono"
        },
        signature = { enabled = true },
        completion = {
          menu = {
            draw = {
              columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "kind", "source_name", gap = 1 },
              },
              treesitter = { "lsp" },
              components = {
                kind = { -- show only Fu in place of Function for example
                  text = function(ctx)
                    return "[" .. ctx.kind:sub(1, 2) .. "]"
                  end,
                }
              }
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 250,
          },
          ghost_text = {
            enabled = false,
          },
        },
      },
    },
    -- replaced by lsp saga if i like it better
    -- { 
    --   "dgagn/diagflow.nvim",
    --   opts = {
    --     event = "LspAttach",
    --     show_borders = true,
    --
    --   }
    -- },
    {
      "CrestNiraj12/compress-size.nvim",
      opts = {},
    },
    {
      "nvimdev/lspsaga.nvim",
      config = function()
        require("lspsaga").setup({
          lightbulb = {
            enable = false
          },
          implement = {
            enable = true,
            sign = true,
            virtual_text = false,
          }
        })
      end,
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
      }
    }
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

---        ---
-- Shortcut --
---        ---
-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
-- oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", require("oil").toggle_float)
-- remove search highlight
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>")
-- lspsaga
-- loop over each one of the diag
vim.keymap.set('n', '[d', '<cmd>Lspsaga diagnostic_jump_next<CR>')
vim.keymap.set('n', ']d', '<cmd>Lspsaga diagnostic_jump_prev<CR>')
-- loop only over error diag
vim.keymap.set("n", "[D", function()
  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "[D", function()
  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
-- show doc and implementation
vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<CR>')
vim.keymap.set('n', '<leader>K', '<cmd>Lspsaga finder imp<CR>')

---                  ---
-- LSP & other config --
---                  ---

-- special config for lua copy pasted
-- from https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls 
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using (most
          -- likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Tell the language server how to find Lua modules same way as Neovim
          -- (see `:h lua-module-load`)
          path = {
            "lua/?.lua",
            "lua/?/init.lua",
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

-- Enable (broadcasting) snippet capability for completion
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Get capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("cssls", {capabilities = capabilities})
vim.lsp.config("html", {capabilities = capabilities})
vim.lsp.config("jsonls", {capabilities = capabilities})
vim.lsp.config("dprint", {capabilities = capabilities})
-- vim.lsp.config("pyright", {capabilities = capabilities})
vim.lsp.config("ruff", {capabilities = capabilities})
vim.lsp.config("emmet_ls", {capabilities = capabilities})
vim.lsp.config("bashls", {capabilities = capabilities})
vim.lsp.config("eslint", {capabilities = capabilities})
vim.lsp.config("groovyls", {capabilities = capabilities})
vim.lsp.config("golangci_lint_ls", {capabilities = capabilities})
vim.lsp.config("emmet_language_server", {capabilities = capabilities})
vim.lsp.config("codebook", {capabilities = capabilities})
vim.lsp.config("svelte", {capabilities = capabilities})
vim.lsp.config("gh_actions_ls", {capabilities = capabilities})
vim.lsp.config("ts_ls", {capabilities = capabilities})
vim.lsp.config("qmlls", {capabilities = capabilities, cmd = {"qmlls6"}})

-- /!\ this lsp has to be installed before hand
vim.lsp.enable("dprint") -- yay -S dprint-bin
vim.lsp.enable("lua_ls") -- yay -S lua-language-server
-- vim.lsp.enable("pyright") -- yay -S pyright
vim.lsp.enable("ruff") -- pip install ruff or sudo pacman -S ruff
vim.lsp.enable("emmet_ls") -- npm install -g emmet-ls
vim.lsp.enable("bashls") -- npm i -g bash-language-server
vim.lsp.enable("eslint") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("groovyls") -- install java with sdkman and yay -S groovy-language-server-git
vim.lsp.enable("golangci_lint_ls") -- go install github.com/nametake/golangci-lint-langserver@latest && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
vim.lsp.enable("cssls") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("emmet_language_server") -- npm install -g @olrtg/emmet-language-server
vim.lsp.enable("html") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("codebook") -- pacman -S codebook-lsp
vim.lsp.enable("svelte") -- npm install -g svelte-language-server
vim.lsp.enable("gh_actions_ls") -- npm install -g gh-actions-language-server
vim.lsp.enable("jsonls") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("ts_ls") -- npm install -g typescript typescript-language-server
vim.lsp.enable("qmlls") -- sudo pacman -S qt6-declarative

---               ---
-- Custom function --
---               ---

local term_augroup = vim.api.nvim_create_augroup("TerminalToggle", { clear = true })

-- open a new window with a terminal in it
local function toggle_terminal()
  -- create buffer if it doesn't exist
  if not vim.g.term_buf or not vim.api.nvim_buf_is_valid(vim.g.term_buf) then
    vim.g.term_buf = vim.api.nvim_create_buf(false, true)
    vim.g.term_job = nil
  end

  -- check if window is already open
  if vim.g.term_win and vim.api.nvim_win_is_valid(vim.g.term_win) then
    vim.api.nvim_win_hide(vim.g.term_win)
    vim.g.term_win = nil
  else
    -- calculate window size
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- open floating window with the terminal buffer
    vim.g.term_win = vim.api.nvim_open_win(vim.g.term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      border = "rounded",
      style = "minimal",
    })

    -- prevent any other buffer to be open in the window
    -- this is mendatory, because if not set we could lost
    -- any term open and see it replace by a new buffer
    -- vim.api.nvim_set_option_value('winfixbuf', true, { win = vim.g.term_win })

    -- auto-close terminal window on buffer leave
    vim.api.nvim_create_autocmd("BufLeave", {
      group = term_augroup,
      buffer = vim.g.term_buf,
      callback = function()
        if vim.g.term_win and vim.api.nvim_win_is_valid(vim.g.term_win) then
          vim.api.nvim_win_hide(vim.g.term_win)
          vim.g.term_win = nil
        end
      end,
    })

    -- start terminal if not already started
    if not vim.g.term_job then
      vim.g.term_job = vim.fn.jobstart(vim.o.shell, {
        term = true,
        pty = true,
      })
    end

    vim.cmd("startinsert")
  end
end

vim.keymap.set({"n"}, "<leader>tt", toggle_terminal, { desc = "Toggle a floating terminal" })
-- exit terminal mode
vim.keymap.set({"t"}, "<leader><esc>", "<c-\\><c-n>")

