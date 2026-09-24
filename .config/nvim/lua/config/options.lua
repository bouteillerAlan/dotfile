local M = {}

function M.setup()
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"
  vim.g.has_nerd_font = true
  vim.opt.hlsearch = true
  vim.opt.clipboard:append("unnamedplus")
  vim.opt.relativenumber = true
  vim.opt.number = true
  vim.g.python_recommended_style = 0
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.opt.colorcolumn = "80"
  vim.opt.list = true
  vim.opt.listchars = { trail = "*", nbsp = "+", tab = string.rep(" ", vim.o.tabstop) }
  vim.opt.undofile = true
  vim.opt.ignorecase = true
  vim.opt.scrolloff = 20
  vim.opt.wrap = false
end

return M
