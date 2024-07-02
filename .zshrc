export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' frequency 3

DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"

plugins=(git zoxide colorize docker docker-compose heroku nvm yarn ruby zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias nv="nvim"
alias ls="eza -la --icons=always --git"
alias usefull-cmd="echo 'duf -- for disk, eza -- for ls, zoxide -- for cd, ripgrep -- for grep, tldr -- for man, glances or bpytop -- for ressource monitor, gping -- for ping, screenfetch -- for info, lolcat and figlet -- for fun' | lolcat"
alias battery="cat /sys/class/power_supply/BAT0/capacity"

export GPG_TTY=$(tty)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/Android/Sdk"

eval "$(starship init zsh)"
