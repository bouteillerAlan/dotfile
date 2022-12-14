local status, packer = pcall(require, 'packer')

if (not status) then
  print('🔥 Packer is not installed')
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(
  function(use)
    use 'wbthomason/packer.nvim'
    use { 'catppuccin/nvim', as = 'catppuccin' } -- theme
    use 'nvim-lualine/lualine.nvim' -- statusline
    use 'nvim-lua/plenary.nvim' -- common utilities
    use 'onsails/lspkind-nvim' -- vscode-like pictograms
    use 'hrsh7th/cmp-buffer' -- nvim-cmp source for buffer words
    use 'hrsh7th/cmp-nvim-lsp' -- nvim-cmp source for neovim built-in LSP
    use 'hrsh7th/nvim-cmp' -- auto completion
    use 'neovim/nvim-lspconfig' -- LSP
    use 'jose-elias-alvarez/null-ls.nvim' -- use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    use 'MunifTanjim/prettier.nvim' -- prettier plugin for Neovim built-in LSP client
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'glepnir/lspsaga.nvim' -- LSP UIs
    use 'L3MON4D3/LuaSnip'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'kyazdani42/nvim-web-devicons' -- file icons
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'nvim-lua/popup.nvim'
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'windwp/nvim-autopairs'
    use 'windwp/nvim-ts-autotag'
    use 'norcalli/nvim-colorizer.lua'
    use 'folke/zen-mode.nvim'
    use({ "iamcco/markdown-preview.nvim", run = function() vim.fn["mkdp#util#install"]() end, })
    use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}
    use 'lewis6991/gitsigns.nvim'
    use 'dinhhuy258/git.nvim' -- For git blame & browse
  end
)
