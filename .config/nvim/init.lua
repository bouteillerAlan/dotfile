require("config.lazy")

-- Filetype detection for JSX/TSX + Prisma
vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
    jsx = "javascriptreact",
    prisma = "prisma",
  },
})
