local M = {}

function M.setup()
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
vim.lsp.config("bashls", {
  capabilities = capabilities,
  filetypes = { "zsh", "sh", "bash" }
})
vim.lsp.config("eslint", {capabilities = capabilities})
vim.lsp.config("groovyls", {capabilities = capabilities})
vim.lsp.config("golangci_lint_ls", {capabilities = capabilities})
vim.lsp.config("emmet_language_server", {
  capabilities = capabilities,
  filetypes = { "html", "css", "scss", "less", "sass", "typescriptreact", "javascriptreact", "typescript", "javascript" },
})
vim.lsp.config("codebook", {capabilities = capabilities})
vim.lsp.config("svelte", {
  capabilities = capabilities,
  settings = {
    svelte = {
      plugin = {
        typescript = {
          inlayHints = {
            parameterTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          }
        }
      }
    }
  }
})
vim.lsp.config("gh_actions_ls", {capabilities = capabilities})
-- Select one TypeScript LSP per workspace: TS < 7 uses ts_ls (tsserver), while
-- TS 7+ uses the native `tsc --lsp`.  In a monorepo, the nearest package.json
-- declaring TypeScript wins; packages without it inherit the declaration above.
local ts_root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", ".git" }
local function ts_project_root(bufnr)
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
  local root = vim.fs.root(bufnr, ts_root_markers) or vim.fn.getcwd()
  if deno_root and #deno_root >= #root then return nil end
  return root
end

local function ts_major_from_package(path)
  if vim.fn.filereadable(path) ~= 1 then return nil end
  local ok, package = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok then return nil end
  local version = (package.devDependencies or {}).typescript
    or (package.dependencies or {}).typescript
    or (package.peerDependencies or {}).typescript
  return type(version) == "string" and tonumber(version:match("(%d+)")) or nil
end

local function ts_lsp_kind(bufnr)
  local root = ts_project_root(bufnr)
  if not root then return nil end
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  while dir and dir:sub(1, #root) == root do
    local major = ts_major_from_package(vim.fs.joinpath(dir, "package.json"))
    if major then return major >= 7 and "tsc" or "ts_ls" end
    if dir == root then break end
    dir = vim.fs.dirname(dir)
  end
  -- No package declaration: prefer native LSP when the default tsc supports it.
  local result = vim.system({ "tsc", "--version" }, { text = true }):wait()
  local major = tonumber((result.stdout or ""):match("Version%s+(%d+)"))
  return major and major >= 7 and "tsc" or "ts_ls"
end

local function ts_root_for(kind)
  return function(bufnr, on_dir)
    if ts_lsp_kind(bufnr) == kind then on_dir(ts_project_root(bufnr)) end
  end
end

-- Keep useful parameter/return hints, but hide inferred local/property types. SDK
-- calls (for example `const response = await client...`) otherwise produce huge
-- inline type labels; use K on the name when the complete inferred type is needed.
vim.lsp.config("tsc", {
  capabilities = capabilities,
  root_dir = ts_root_for("tsc"),
  settings = {
    ["js/ts"] = {
      inlayHints = {
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = false },
        parameterNames = { enabled = "none" },
      },
    },
  },
})
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
  root_dir = ts_root_for("ts_ls"),
})
vim.lsp.config("prismals", {
  capabilities = capabilities,
  filetypes = { "prisma" },
})
vim.lsp.config("gopls", {capabilities = capabilities})
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
-- clangd's semantic tokens override treesitter and rose-pine lacks the
-- @lsp.type.* groups for C, making everything gray — disable them so
-- treesitter highlighting takes over
vim.lsp.config("clangd", {
  capabilities = capabilities,
  on_attach = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
-- tailwind: class autocomplete inside cn(...)/cva(...) (react-native-reusables / nativewind)
vim.lsp.config("tailwindcss", {
  capabilities = capabilities,
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          "cn\\(([^)]*)\\)",
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
        },
      },
    },
  },
})

-- /!\ this lsp has to be installed before hand
vim.lsp.enable("groovyls") -- yay -S groovy-language-server-git
vim.lsp.enable("sqls") -- go install github.com/sqls-server/sqls@latest
vim.lsp.enable("bashls") -- npm i -g bash-language-server
vim.lsp.enable("dprint") -- yay -S dprint-bin
vim.lsp.enable("lua_ls") -- yay -S lua-language-server
vim.lsp.enable("pyright") -- yay -S pyright
vim.lsp.enable("ruff") -- pip install ruff or sudo pacman -S ruff
-- vim.lsp.enable("emmet_ls") -- npm install -g emmet-ls
vim.lsp.enable("bashls") -- npm i -g bash-language-server
vim.lsp.enable("eslint") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("groovyls") -- install java with sdkman and yay -S groovy-language-server-git
vim.lsp.enable("gopls") -- go install golang.org/x/tools/gopls@latest
vim.lsp.enable("golangci_lint_ls") -- go install github.com/nametake/golangci-lint-langserver@latest && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
vim.lsp.enable("cssls") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("emmet_language_server") -- npm install -g @olrtg/emmet-language-server
vim.lsp.enable("html") -- npm i -g vscode-langservers-extracted
vim.lsp.enable("codebook") -- pacman -S codebook-lsp
vim.lsp.enable("svelte") -- npm install -g svelte-language-server
vim.lsp.enable("gh_actions_ls") -- npm install -g gh-actions-language-server
vim.lsp.enable("jsonls") -- npm i -g vscode-langservers-extracted
vim.lsp.enable({ "tsc", "ts_ls" }) -- selected from the nearest TypeScript version declaration
vim.lsp.enable("qmlls") -- sudo pacman -S qt6-declarative
vim.lsp.enable("clangd")
vim.lsp.enable("tailwindcss") -- npm i -g @tailwindcss/language-server
vim.lsp.enable("prismals") -- npm install -g @prisma/language-server


end

return M
