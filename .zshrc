export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' frequency 3

DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"

plugins=(git zoxide colorize docker docker-compose heroku nvm yarn ruby zsh-syntax-highlighting zsh-autosuggestions dockolor poetry)

source $ZSH/oh-my-zsh.sh

alias nv="nvim"
#alias ls="eza -la --icons=always --git"
alias usefull-cmd="echo 'duf -- for disk, eza -- for ls, zoxide -- for cd, ripgrep -- for grep, tldr -- for man, glances or bpytop -- for ressource monitor, gping -- for ping, screenfetch -- for info, lolcat and figlet -- for fun' | lolcat"
alias battery="cat /sys/class/power_supply/BAT0/capacity"

# source the env for rust
. "$HOME/.cargo/env"

# go
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

export GPG_TTY=$(tty)
#export VOLTA_HOME="$HOME/.volta"
#export PATH="$VOLTA_HOME/bin:$PATH"
#export ANDROID_HOME="$HOME/Android/Sdk"
#export PATH="$HOME/.symfony5/bin:$PATH"
export SUDO_EDITOR="nvim"

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

# bun completions
#[ -s "/home/a2n/.bun/_bun" ] && source "/home/a2n/.bun/_bun"

# bun
#export BUN_INSTALL="$HOME/.bun"
#export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

