return {
      "igorlfs/nvim-dap-view",
      lazy = false,
      config = function()
        require("dap-view").setup({
          auto_toggle = true,
          virtual_text = { enabled = true },
          winbar = {
            controls = {
              enabled = true
            }
          }
        })
      end,
    }
