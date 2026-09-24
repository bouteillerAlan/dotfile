return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("config.treesitter_progress").begin()
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
      "prisma",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "vim",
      "yaml",
      "toml",
      "qmljs",
      "c",
      "c_sharp"
    }
  end
}
