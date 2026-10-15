return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      options = {
        severity = {
          vim.diagnostic.severity.ERROR
        },
        show_source = {
          enabled = true
        },
        set_arrow_to_diag_color = true,
      }
    })
    -- vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
  end,
}
