return {
      "uhs-robert/oasis.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("oasis").setup({
          style = "moonlight",
        })
        vim.cmd.colorscheme("oasis")
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
