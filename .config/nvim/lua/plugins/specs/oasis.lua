return {
      "uhs-robert/oasis.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("oasis").setup({
          style = "moonlight",
        })
        vim.cmd.colorscheme("oasis")

        -- Hermes gold borders (see ~/Documents/know/hermes-cli-statusbar.md),
        -- matching the tmux pane-border-style gold. Window separators and
        -- floating window borders (hover, Telescope, ...) were steelblue
        -- from the oasis colorscheme; recolor them to gold.
        local gold = "#FFD700"
        local gold_hot = "#FFBF00"
        local dim = "#8A7A4A"
        local good = "#8FBC8F"
        local warn = "#FF8C00"
        local critical = "#FF6B6B"
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = gold })
        vim.api.nvim_set_hl(0, "VertSplit", { fg = gold })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = gold })

        -- Diagnostics and git-diff signs were oasis's own pastel colors
        -- (soft pink/khaki/mint), not Hermes. This recolors them everywhere
        -- (gutter signs, inline virtual text, hover popups), not just the
        -- statusline segment, since they share the same highlight groups.
        -- Escalating emphasis: hint < info < warn < error.
        vim.api.nvim_set_hl(0, "DiagnosticError", { fg = critical })
        vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = warn })
        vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = gold_hot })
        vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = dim })
        vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = good })
        vim.api.nvim_set_hl(0, "GitSignsChange", { fg = warn })
        vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = critical })
      end
    }
    -- {
    --   "folke/tokyonight.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   opts = {},
    --   config = function()
    --     vim.cmd("colorscheme tokyonight-night")
    --   end
    -- },
