return {
  "folke/trouble.nvim",
  opts = {
    focus = true,
    keys = {
      ["<esc>"] = "close",
    },
    modes = {
      -- Trouble's right-hand symbols pane defaults to 30 columns.
      symbols = { win = { size = 60 } },
    },
  },
  cmd = "Trouble",
}
