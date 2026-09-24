return {
      "goolord/alpha-nvim",
      dependencies = {
        "nvim-mini/mini.icons",
        "nvim-lua/plenary.nvim",
      },
      config = function()
        local alpha = require("alpha")
        local theta = require("alpha.themes.theta")
        local dashboard = require("alpha.themes.dashboard")

        -- retro palette: red, orange, amber, brown
        local retro_colors = { "#d70000", "#ff5f00", "#ffaf00", "#875f00" }
        for i, hex in ipairs(retro_colors) do
          vim.api.nvim_set_hl(0, "AlphaHeaderRetro" .. i, { fg = hex })
        end

        local n_colors = #retro_colors
        local n_lines = #theta.header.val
        local offset = 0

        -- color each header line, cycling through the palette
        local function apply_header_colors()
          theta.header.opts.hl = {}
          for i = 1, n_lines do
            local group = "AlphaHeaderRetro" .. (((i - 1 + offset) % n_colors) + 1)
            theta.header.opts.hl[i] = { { group, 0, -1 } }
          end
        end
        apply_header_colors()

        -- animate: flow the palette down the header, looping
        local uv = vim.uv or vim.loop
        local timer = nil
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "alpha",
          callback = function(args)
            if timer then return end
            timer = uv.new_timer()
            timer:start(0, 190, vim.schedule_wrap(function()
              if not vim.api.nvim_buf_is_valid(args.buf) then
                if timer then timer:stop(); timer:close(); timer = nil end
                return
              end
              offset = (offset - 1) % n_colors
              apply_header_colors()
              if vim.api.nvim_get_current_buf() == args.buf then
                alpha.redraw()
              end
            end))
            vim.api.nvim_create_autocmd("BufUnload", {
              buffer = args.buf,
              once = true,
              callback = function()
                if timer then
                  timer:stop()
                  timer:close()
                  timer = nil
                end
              end,
            })
          end,
        })

        theta.buttons.val = {
          dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
          dashboard.button("SPC f f", "  Find file", ":Telescope find_files<CR>"),
          dashboard.button("SPC f r", "  Recent files", ":Telescope oldfiles<CR>"),
          dashboard.button("SPC f g", "󰱼  Live grep", ":Telescope live_grep<CR>"),
          dashboard.button("u", "󰚰  Update plugins", ":Lazy sync<CR>"),
          dashboard.button("q", "󰩈  Quit", ":qa<CR>"),
        }

        alpha.setup(theta.config)
      end,
    }
