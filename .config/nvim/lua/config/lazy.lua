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
-- - `[d` and `]d` to navigate all diagnostic and `[D` `]D` to loop over the error one
-- - `K` give you the description and `leader K` the implementation
--
-- Some reminder:
-- - `:%s/string/string/g(c)` to replace all or with `c` to confirm
-- - `/` to search a pattern, then `n` or `N` to loop over it
-- - `ctrl+]` to go to definition and `ctrl+t` to return back
-- - `gg` and `G` to move top/bottom
-- - indent with `=`
-- - delete all ligne that contain "test": `:g/test/norm dd`
-- `%` on `{` (for example) go to the closing/openning one
-- za to fold/unfold
-- zR/zM to un/fold all

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
-- allow to fold/unfold code block
-- vim.opt.foldmethod = "syntax" >> treesitter provide it
-- show trailling space
vim.opt.list = true
vim.opt.listchars = { trail = "*", nbsp = "+", tab = string.rep(" ", vim.o.tabstop)}
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
      config = function()
        require("lualine").setup({
          sections = {
            lualine_c = {
              "filename",
              function()
                return require("compress_size").status()
              end,
            },
          },
        })
      end
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
          "toml",
          "qmljs"
        }
      end
    },
    {
      "nvim-java/nvim-java", config = function()
        require("java").setup()
        vim.lsp.enable("jdtls")
      end,
    },
    {
      "neovim/nvim-lspconfig"
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install"
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "v0.1.9",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-node-modules.nvim",
        "smartpde/telescope-recent-files",
      },
      config = function()
        require("telescope").setup({
          defaults = {
            layout_strategy = "vertical",
            layout_config = { height = 0.95 },
          },
          extensions = {
            recent_files = {
              only_cwd = true
            }
          }
        })
        require("telescope").load_extension("node_modules")
        require("telescope").load_extension("recent_files")
      end
    },
    {
      "tpope/vim-fugitive"
    },
    {
      "nvim-mini/mini.animate",
      version = "*",
      config = function() require("mini.animate").setup() end
    },
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
        keywords = {
          TODO = {icon= "*", alt = {"todo"}},
          FIX = {icon= "*", alt = {"fix", "fixme", "bug", "issue", "FIXME", "BUG", "FIXIT", "ISSUE"}},
          HACK = {icon= "*", alt = {"hack"}},
          WARN = {icon= "*", alt = {"warn", "warning"}},
          NOTE = {icon= "*", alt = {"note", "info", "INFO" }},
        }
      },
    },
    {
      "nvim-mini/mini.hipatterns",
      version = "*",
      config = function()
        local hipatterns = require("mini.hipatterns")
        hipatterns.setup({
          highlighters = {
            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })
      end
    },
    {
      "nvim-mini/mini.icons",
      version = "*",
      config = function() require("mini.icons").setup() end
    },
    {
      "nvim-mini/mini.pairs",
      version = "*",
      config = function() require("mini.pairs").setup() end
    },
    {
      "nvim-mini/mini.diff",
      version = "*",
      config = function() require("mini.diff").setup({view={style="number"}}) end
    },
    {
      "mfussenegger/nvim-dap"
    },
    {
      "dstein64/vim-startuptime"
    },
    {
      "lewis6991/gitsigns.nvim",
      config = function() require("gitsigns").setup({current_line_blame = true}) end
    },
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
        keymap = {
          preset = "default",
          ['<Tab>'] = { 'select_and_accept', 'fallback' },
        },
        appearance = {
          nerd_font_variant = "mono"
        },
        signature = { enabled = true, trigger = { enabled = true } },
        completion = {
          accept = {
            -- auto add brackets/parens when accepting a function/method completion
            auto_brackets = { enabled = true },
          },
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
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          providers = (function()
            -- offsets shift the fuzzy score to enforce source priority tiers
            -- gap must stay smaller than a strong fuzzy match (~10-50) so a
            -- perfect snippet still beats a weak LSP result
            local tier = 3
            return {
              lsp      = { score_offset =  tier     }, -- +3: highest
              snippets = { score_offset = -tier     }, -- -3: below lsp
              buffer   = { score_offset = -tier * 2 }, -- -6: last resort
            }
          end)(),
        },
      },
    },
    {
      "dgagn/diagflow.nvim",
      opts = {
        show_sign = true,
        event = "LspAttach",
        show_borders = false,
        -- placement = "inline"
      }
    },
    {
      "folke/trouble.nvim",
      opts = {
        focus = true,
        keys = {
          ["<esc>"] = "close",
        }
      },
      cmd = "Trouble",
    },
    {
      "CrestNiraj12/compress-size.nvim",
      opts = {},
      config = function () require("compress_size").setup() end
    },
    {
      "smjonas/inc-rename.nvim",
      opts = {}
    },
    {
      "TheNoeTrevino/haunt.nvim",
      opts = {picker="telescope"},
      init = function()
        local haunt = require("haunt.api")
        local haunt_picker = require("haunt.picker")
        local map = vim.keymap.set
        local prefix = "<leader>h"

        -- annotations
        map("n", prefix .. "a", function()
          haunt.annotate()
        end, { desc = "Annotate" })

        map("n", prefix .. "T", function()
          haunt.toggle_all_lines()
        end, { desc = "Toggle all annotations" })

        map("n", prefix .. "d", function()
          haunt.delete()
        end, { desc = "Delete bookmark" })

        -- move
        map("n", prefix .. "p", function()
          haunt.prev()
        end, { desc = "Previous bookmark" })

        map("n", prefix .. "n", function()
          haunt.next()
        end, { desc = "Next bookmark" })

        -- picker
        map("n", prefix .. "l", function()
          haunt_picker.show()
        end, { desc = "Show Picker" })

        -- quickfix
        map("n", prefix .. "q", function()
          haunt.to_quickfix()
        end, { desc = "Send Hauntings to QF Lix (buffer)" })

        map("n", prefix .. "Q", function()
          haunt.to_quickfix({ current_buffer = true })
        end, { desc = "Send Hauntings to QF Lix (all)" })

        -- yank
        map("n", prefix .. "y", function()
          haunt.yank_locations({current_buffer = true})
        end, { desc = "Send Hauntings to Clipboard (buffer)" })

        map("n", prefix .. "Y", function()
          haunt.yank_locations()
        end, { desc = "Send Hauntings to Clipboard (all)" })

      end,
    },
    {
      "goolord/alpha-nvim",
      dependencies = {
        "nvim-mini/mini.icons",
        "nvim-lua/plenary.nvim",
      },
      config = function()
        local alpha = require("alpha")
        local theta = require("alpha.themes.theta")
        local dashboard = require("alpha.themes.dashboard")

        theta.buttons.val = {
          dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
          dashboard.button("SPC f f", "  Find file", ":Telescope find_files<CR>"),
          dashboard.button("SPC f r", "  Recent files", ":Telescope oldfiles<CR>"),
          dashboard.button("SPC f g", "󰱼  Live grep", ":Telescope live_grep<CR>"),
          dashboard.button("u", "󰚰  Update plugins", ":Lazy sync<CR>"),
          dashboard.button("q", "󰩈  Quit", ":qa<CR>"),
        }

        alpha.setup(theta.config)
      end,
    },
    {
      "mbbill/undotree",
      config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_SetFocusWhenToggle = 1
      end,
    },
    {
      "NickvanDyke/opencode.nvim",
      dependencies = {
        -- Recommended for `ask()` and `select()`.
        -- Required for `snacks` provider.
        -- ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
        -- { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
      },
      config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {
          -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true

        vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
        vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
        vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })
        vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
        vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
        vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
        vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })
        vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
        vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
      end,
    },
  },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

---        ---
-- Shortcut --
---        ---
-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {desc = "Telescope find files"})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {desc = "Telescope live grep"})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {desc = "Telescope buffers"})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {desc = "Telescope help tags"})
-- for todo list
vim.keymap.set("n", "<leader>ft", "<CMD>TodoTelescope<CR>", {desc = "Telescope todo list"})
-- for recent file
vim.keymap.set("n", "<Leader>fr", "<cmd>lua require('telescope').extensions.recent_files.pick()<CR>", {desc = "telescope recent file"})

-- oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", require("oil").toggle_float)

-- remove search highlight
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>")

-- todo list
vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })

-- trouble
vim.keymap.set("n", "<leader>dD", "<cmd>Trouble diagnostics toggle<cr>", {desc = "Diagnostics (Trouble)"})
vim.keymap.set("n", "<leader>dd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", {desc = "Buffer Diagnostics (Trouble)"})
vim.keymap.set("n", "<leader>ts", "<cmd>Trouble symbols toggle focus=true<cr>", {desc = "Symbols (Trouble)"})
vim.keymap.set("n", "<leader>tl", "<cmd>Trouble loclist toggle<cr>", {desc = "Location List (Trouble)"})
vim.keymap.set("n", "<leader>tq", "<cmd>Trouble qflist toggle<cr>", {desc = "Quickfix List (Trouble)"})

-- rename
-- this one show the old value in the prompt, useful to edit it for example
vim.keymap.set("n", "<leader>rn", function() return ":IncRename " .. vim.fn.expand("<cword>") end, { expr = true })
-- vim.keymap.set("n", "<leader>rn", ":IncRename ")

-- LSP navigation with Trouble integration
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    -- enable inlay hints (inline type info, param names, return types)
    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    -- goto def is <C-]> that I prefer because we can use <C-t> to go back
    -- vim.keymap.set('n', 'gd', function() require('trouble').toggle('lsp_definitions') end, vim.tbl_extend('force', opts, { desc = 'LSP Definition' }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = "LSP Declaration" }))
    vim.keymap.set("n", 'gi', function() require('trouble').toggle('lsp_implementations') end, vim.tbl_extend('force', opts, { desc = 'LSP Implementation' }))
    vim.keymap.set('n', '<leader>K', function() require('trouble').toggle('lsp_references') end, vim.tbl_extend('force', opts, { desc = 'LSP References' }))
    vim.keymap.set('n', 'gt', function() require('trouble').toggle('lsp_type_definitions') end, vim.tbl_extend('force', opts, { desc = 'LSP Type Definition' }))
    -- toggle inlay hints on/off per buffer
    vim.keymap.set('n', '<leader>ih', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, vim.tbl_extend('force', opts, { desc = 'Toggle inlay hints' }))
  end
})

-- undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- custom one
vim.keymap.set('n', '<C-z>', '<cmd>undo<cr>', {desc = 'undo one change'})

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
      Lua = {
        hint = {
          enable = true,
          paramName = "Disable",
          setType = true,
          arrayIndex = "Disable",
          returnAnonymousFunction = true,
        }
      }
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
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    pyright = {
      -- ruff handles imports, let it own that
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = "basic",
        -- let ruff handle all linting diagnostics, pyright focuses on types
        ignore = { "*" },
        autoImportCompletions = true,
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
        },
      }
    }
  }
})
vim.lsp.config("ruff", {capabilities = capabilities})
vim.lsp.config("emmet_ls", {
  capabilities = capabilities,
  filetypes = { "html", "css", "scss", "less", "sass", "typescriptreact" },
})
vim.lsp.config("bashls", {capabilities = capabilities})
vim.lsp.config("eslint", {capabilities = capabilities})
vim.lsp.config("groovyls", {capabilities = capabilities})
vim.lsp.config("golangci_lint_ls", {capabilities = capabilities})
vim.lsp.config("emmet_language_server", {
  capabilities = capabilities,
  filetypes = { "html", "css", "scss", "less", "sass", "typescriptreact" },
})
vim.lsp.config("codebook", {capabilities = capabilities})
vim.lsp.config("svelte", {
  capabilities = capabilities,
  settings = {
    svelte = {
      plugin = {
        typescript = {
          inlayHints = {
            parameterTypes        = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues      = { enabled = true },
          }
        }
      }
    }
  }
})
vim.lsp.config("gh_actions_ls", {capabilities = capabilities})
local ts_inlay_hints = {
  includeInlayFunctionParameterTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
  init_options = {
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsWithInsertText = true,
      importModuleSpecifierPreference = "shortest",
    }
  },
  settings = {
    typescript = { inlayHints = ts_inlay_hints },
    javascript = { inlayHints = ts_inlay_hints },
  }
})
vim.lsp.config("qmlls", {capabilities = capabilities, cmd = {"qmlls6"}})
vim.lsp.config("bashls", {capabilities = capabilities})
vim.lsp.config("sqls", {capabilities = capabilities})
vim.lsp.config('groovyls', {
  cmd = {
    "java",
    "-jar",
    "/usr/share/java/groovy-language-server/groovy-language-server-all.jar",
  },
  capabilities = capabilities,
})

-- /!\ this lsp has to be installed before hand
vim.lsp.enable("groovyls") -- yay -S groovy-language-server-git
vim.lsp.enable("sqls") -- go install github.com/sqls-server/sqls@latest
vim.lsp.enable("bashls") -- npm i -g bash-language-server
vim.lsp.enable("dprint") -- yay -S dprint-bin
vim.lsp.enable("lua_ls") -- yay -S lua-language-server
vim.lsp.enable("pyright") -- yay -S pyright
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

-- treesitter special config --
-- folding & indent
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    -- enable treesitter highlighting (new nvim-treesitter main branch no longer does this automatically)
    pcall(vim.treesitter.start)
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldlevel = 99  -- Open all folds by default
    -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
})

---               ---
-- Custom function --
---               ---

--
-- floating terminal
--
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

