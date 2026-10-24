export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="robbyrussell"
# ZSH_THEME="miel"
source ~/.config/miel/oh-my-zsh/themes/miel.zsh-theme

zstyle ':omz:update' frequency 3

DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"

plugins=(git zoxide colorize docker docker-compose heroku nvm yarn ruby zsh-syntax-highlighting zsh-autosuggestions dockolor poetry uv)

source $ZSH/oh-my-zsh.sh

# docker buildkit
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Set up neovim as the default editor.
export EDITOR="$(which nvim)"
export VISUAL="$EDITOR"

alias show='eww reload & awww img --transition-type wipe --transition-step 90 --transition-fps 60 --transition-angle 30 /home/a2n/Nextcloud/photos/wallpaper/best/tyler-lastovich-ddLiNMqWAOM-unsplash.jpg'

alias oui='echo "Ho?"'
alias yes='echo "Ho?"'

alias :r="source ~/.zshrc"
alias reload="source ~/.zshrc"

alias :t="tmux"
alias :h="herdr"
alias :q="exit"
alias :c="claude"

alias gdh="git diff HEAD"
alias nv="nvim"
alias ls="eza -la --icons=always --git"
alias brain="echo 'duf -- for disk, eza -- for ls, zoxide -- for cd, ripgrep -- for grep, tldr -- for man, glances or bpytop -- for ressource monitor, gping -- for ping, screenfetch -- for info, lolcat and figlet -- for fun' | lolcat"
alias batt="cat /sys/class/power_supply/BAT0/capacity"

alias dstart="sudo systemctl start docker"

# allow term in ssh to get kitty profile
# alias ssh="kitten ssh"

# source the env for rust
# . "$HOME/.cargo/env"

# devcontainer
export PATH="$HOME/.devcontainers/bin:$PATH"

# go
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

# usefull for kitty
# export GPG_TTY=$(tty)

export ANDROID_HOME="$HOME/Android/Sdk"
# for emulator
export PATH="$PATH:$HOME/Android/Sdk/emulator/"
# for adb
export PATH="$PATH:$HOME/Android/Sdk/platform-tools/"
# symfony
export PATH="$HOME/.symfony5/bin:$PATH"

# force editor for sudo user
export SUDO_EDITOR="nvim -u /home/a2n/.config/nvim"

# eval "$(starship init zsh)"
# eval "$(/home/a2n/.local/bin/oh-my-posh init zsh --config /home/a2n/.config/oh-my-posh/star.omp.json)"
# eval "$(zellij setup --generate-auto-start zsh)"
# eval "$(oh-my-posh init zsh --config ~/.config/miel/oh-my-posh/themes/miel.omp.json)"

# PYTHON
# need pyenv pyenv-virtualenv poetry
# PYENV
#export PATH="$HOME/.pyenv/bin:$PATH"
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"
# POETRY
#export PATH="$HOME/.local/bin:$PATH"

# SDKMAN_DIR
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# pnpm
# export PNPM_HOME="/home/a2n/.local/share/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac

# Pulumi
export PATH=$PATH:/home/a2n/.pulumi/bin

# bun completions
[ -s "/home/a2n/.bun/_bun" ] && source "/home/a2n/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Created by `pipx` on 2025-12-18 09:47:55
export PATH="$PATH:$HOME/.local/bin"

# force the terminal to use zen browser
export BROWSER=zen-browser

# doom emacs
export PATH="$PATH:$HOME/.config/emacs/bin"

# opencode
export PATH=/home/a2n/.opencode/bin:$PATH

# atuin
# . "$HOME/.atuin/bin/env"
# eval "$(atuin init zsh)"
# eval "$(~/.local/bin/mise activate zsh)"

# mise en place
eval "$(/home/a2n/.local/bin/mise activate zsh)"

eval "$(/home/a2n/.local/bin/mise activate zsh)" # added by https://mise.run/zsh
