return {
  dir = vim.fn.expand("~/.config/miel"),
  dependencies = {
    "uhs-robert/oasis.nvim",
    "nvim-lualine/lualine.nvim",
    "goolord/alpha-nvim",
    "nvim-mini/mini.icons",
    "nvim-lua/plenary.nvim",
  },
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/neovim")
    require("miel").setup()
  end,
}
