return {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        -- telescope-style path shortening
        local function shorten_path(path, keep)
          keep = keep or 3
          local prefix = ""
          if path:sub(1, 1) == "/" then
            prefix = "/"
            path = path:sub(2)
          end
          local parts = vim.split(path, "/", { plain = true })
          local n = #parts
          if n > keep then
            for i = 1, n - keep do
              if parts[i] ~= "" and parts[i] ~= "~" and parts[i] ~= ".." then
                parts[i] = parts[i]:sub(1, 1)
              end
            end
          end
          return prefix .. table.concat(parts, "/")
        end

        local function shortened_filepath()
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname == "" then
            return "[No Name]"
          end
          -- ":p" -> always the full absolute path, like `pwd`
          local path = vim.fn.fnamemodify(bufname, ":p")
          local result = shorten_path(path, 3)
          if vim.bo.modified then
            result = result .. " [+]"
          end
          if vim.bo.readonly then
            result = result .. " [RO]"
          end
          return result
        end

        -- LSP/treesitter loading progress is shown by fidget.nvim (see its
        -- plugin spec below) as floating notifications, not in here.
        require("lualine").setup({
          sections = {
            lualine_c = {
              shortened_filepath,
              function()
                return require("compress_size").status()
              end,
            },
            lualine_x = {
              "encoding",
              "fileformat",
              "filetype",
              "dap_breakpoints",
              function()
                return os.date("%Y-%m-%d %H:%M")
              end,
            },
          },
        })
      end
    }
