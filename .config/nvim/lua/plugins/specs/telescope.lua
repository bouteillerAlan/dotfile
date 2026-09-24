return {
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
}
