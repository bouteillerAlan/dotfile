require("config.lazy")

-- Filetype detection for JSX/TSX
vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
    jsx = "javascriptreact",
  },
})
