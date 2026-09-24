return {
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
}
