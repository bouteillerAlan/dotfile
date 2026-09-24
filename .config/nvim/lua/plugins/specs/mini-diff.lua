return {
      "nvim-mini/mini.diff",
      version = "*",
      config = function() require("mini.diff").setup({view={style="number"}}) end
    }
