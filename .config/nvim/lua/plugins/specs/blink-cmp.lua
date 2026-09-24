return {
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
        signature = { enabled = true, trigger = { enabled = true, show_on_keyword = true } },
        completion = {
          accept = {
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
              -- components = {
              --   kind = { -- show only Fu in place of Function for example
              --     text = function(ctx)
              --       if ctx.kind == "Function" then
              --         return "fc()"
              --       end
              --       if ctx.kind == "Method" then
              --         return "Meth"
              --       end
              --       if ctx.kind == "Variable" then
              --         return "var"
              --       end
              --       if ctx.kind == "Snippet" then
              --         return "snip"
              --       end
              --       if ctx.kind == "Keyword" then
              --         return "keyw"
              --       end
              --       return ctx.kind
              --     end,
              --   }
              -- }
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
        -- sources = {
        --   default = { 'lsp', 'path', 'snippets', 'buffer' },
        --   providers = (function()
        --     -- offsets shift the fuzzy score to enforce source priority tiers
        --     -- gap must stay smaller than a strong fuzzy match (~10-50) so a
        --     -- perfect snippet still beats a weak LSP result
        --     local tier = 3
        --     return {
        --       lsp      = { score_offset =  tier     }, -- +3: highest
        --       snippets = { score_offset = -tier     }, -- -3: below lsp
        --       buffer   = { score_offset = -tier * 2 }, -- -6: last resort
        --     }
        --   end)(),
        -- },
      },
    }
