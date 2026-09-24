return {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          current_line_blame = true,
          on_attach = function(bufnr)
            local gs = require("gitsigns")
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end
            map("n", "]g", function() gs.nav_hunk("next", { buffer = bufnr }) end, { desc = "Next git hunk" })
            map("n", "[g", function() gs.nav_hunk("prev", { buffer = bufnr }) end, { desc = "Previous git hunk" })
          end,
        })
      end
    }
