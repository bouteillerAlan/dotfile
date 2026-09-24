return {
      "j-hui/fidget.nvim",
      -- lazy=false + high priority: loaded before treesitter's config
      -- below, which needs fidget.progress.handle already on the
      -- runtimepath to report its own install progress into it
      lazy = false,
      priority = 1000,
      opts = {},
    }
