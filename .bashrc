#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/a2n/.sdkman"
[[ -s "/home/a2n/.sdkman/bin/sdkman-init.sh" ]] && source "/home/a2n/.sdkman/bin/sdkman-init.sh"

. "$HOME/.atuin/bin/env"
eval "$(atuin init bash)"
