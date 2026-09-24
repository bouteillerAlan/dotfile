local M = {}

function M.setup()
  -- treesitter special config --
  -- use bash parser for zsh files (no dedicated zsh parser)
  vim.treesitter.language.register('bash', 'zsh')
  -- folding & indent
  vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
      -- enable treesitter highlighting (new nvim-treesitter main branch no longer does this automatically)
      local ok = pcall(vim.treesitter.start)
      if ok then
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
      else
        vim.wo[0][0].foldmethod = 'indent'
      end
      vim.wo[0][0].foldlevel = 99  -- Open all folds by default
    end
  })

  vim.filetype.add({
    extension = {
      tsx = "typescriptreact",
      jsx = "javascriptreact",
      prisma = "prisma",
    },
  })

  -- Treesitter's own indentexpr has no special case for `/** */` continuation
  -- lines though (it doesn't do "align `*` under the second char of `/**`"),
  -- so JSDoc bodies still come out wrong on their own. Special-case those
  -- lines here, defer to treesitter for everything else.
  function _G.__js_ts_indent()
    local lnum = vim.v.lnum
    local line = vim.fn.getline(lnum)
    local prevlnum = vim.fn.prevnonblank(lnum - 1)
    local prevline = vim.fn.getline(prevlnum)

    if line:match('^%s*%*') then
      if prevline:match('^%s*/%*') then
        -- previous line opened the comment (`/**`): align one column past it
        return vim.fn.indent(prevlnum) + 1
      elseif prevline:match('^%s*%*') then
        -- previous line was itself a `*` continuation: match it exactly
        return vim.fn.indent(prevlnum)
      end
    end

    return require('nvim-treesitter').indentexpr()
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescriptreact', 'javascriptreact', 'typescript', 'javascript' },
    callback = function()
      vim.bo.indentexpr = "v:lua.__js_ts_indent()"
    end
  })

end

return M
