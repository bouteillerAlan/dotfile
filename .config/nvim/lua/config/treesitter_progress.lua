local M = { handle = nil }

function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    desc = "Report treesitter parser (re)install completion to fidget.nvim",
    callback = function()
      if M.handle then
        M.handle:finish()
        M.handle = nil
      end
    end,
  })
end

function M.begin()
  M.handle = require("fidget.progress.handle").create({
    title = "Treesitter",
    message = "Installing parsers",
    lsp_client = { name = "treesitter" },
  })
end

return M
