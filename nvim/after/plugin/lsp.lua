local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
 lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
 ensure_installed = {'tsserver', 'rust_analyzer', 'lua_ls'},
 handlers = {
 lsp_zero.default_setup,
 },
})

lsp_zero.set_sign_icons({
 error = '✘',
 warn = '▲',
 hint = '⚑',
 info = '»'
})
