#!/bin/bash

yay -S groovy-language-server-git dprint-bin lua-language-server pyright groovy-language-server-git
sudo pacman -S qt6-declarative codebook-lsp

# go install github.com/sqls-server/sqls@latest
# go install golang.org/x/tools/gopls@latest
# go install github.com/nametake/golangci-lint-langserver@latest
# go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# pip install ruff or sudo pacman -S ruff

npm i -g bash-language-server emmet-ls bash-language-server vscode-langservers-extracted @olrtg/emmet-language-server svelte-language-server gh-actions-language-server typescript typescript-language-server

