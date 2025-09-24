export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' frequency 3

DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"

plugins=(git zoxide colorize docker docker-compose heroku nvm yarn ruby zsh-syntax-highlighting zsh-autosuggestions dockolor poetry)

source $ZSH/oh-my-zsh.sh

alias nv="nvim"
alias ls="eza -la --icons=always --git"
alias brain="echo 'duf -- for disk, eza -- for ls, zoxide -- for cd, ripgrep -- for grep, tldr -- for man, glances or bpytop -- for ressource monitor, gping -- for ping, screenfetch -- for info, lolcat and figlet -- for fun' | lolcat"
alias batt="cat /sys/class/power_supply/BAT0/capacity"

# source the env for rust
. "$HOME/.cargo/env"

# go
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

# usefull for kitty
export GPG_TTY=$(tty)

#export ANDROID_HOME="$HOME/Android/Sdk"
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

