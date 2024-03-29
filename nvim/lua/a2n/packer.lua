vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.4', requires = { {'nvim-lua/plenary.nvim'} } }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'j-hui/fidget.nvim', tag = 'legacy' }
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- manage LSP from neovim
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},
            -- LSP Support
            {'neovim/nvim-lspconfig'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'L3MON4D3/LuaSnip'},
        }
    }
    use { 'catppuccin/nvim', as = 'catppuccin' }
end)
