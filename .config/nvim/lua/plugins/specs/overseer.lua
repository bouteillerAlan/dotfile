return {
  "stevearc/overseer.nvim",
  ---@module 'overseer'
  ---@type overseer.SetupOpts
  opts = {templates = { "builtin" }},
  config = function ()
    require("overseer").setup()
  end
}
