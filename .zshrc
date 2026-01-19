export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' frequency 3

DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"

plugins=(git zoxide colorize docker docker-compose heroku nvm yarn ruby zsh-syntax-highlighting zsh-autosuggestions dockolor poetry uv)

source $ZSH/oh-my-zsh.sh

# Set up neovim as the default editor.
export EDITOR="$(which nvim)"
export VISUAL="$EDITOR"

alias nv="nvim"
alias ls="eza -la --icons=always --git"
alias brain="echo 'duf -- for disk, eza -- for ls, zoxide -- for cd, ripgrep -- for grep, tldr -- for man, glances or bpytop -- for ressource monitor, gping -- for ping, screenfetch -- for info, lolcat and figlet -- for fun' | lolcat"
alias batt="cat /sys/class/power_supply/BAT0/capacity"

# source the env for rust
#. "$HOME/.cargo/env"

# volta
export PATH="$HOME/.volta/bin:$PATH"

# go
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

# usefull for kitty
export GPG_TTY=$(tty)

export ANDROID_HOME="$HOME/Android/Sdk"
#export PATH="$HOME/.symfony5/bin:$PATH"

# force editor for sudo user
export SUDO_EDITOR="nvim"

# set starship
eval "$(starship init zsh)"

# ----------------------
# PYTHON
# ----------------------
# need pyenv pyenv-virtualenv poetry
# PYENV
#export PATH="$HOME/.pyenv/bin:$PATH"
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"
# POETRY
#export PATH="$HOME/.local/bin:$PATH"
# -----------------------

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# pnpm
export PNPM_HOME="/home/a2n/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# deno
#. "/home/a2n/.deno/env"

# add Pulumi to the PATH
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
