# Copyright (C) 2026 Bouteiller [a2n] Alan <a2n.dev@pm.me>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

#!/usr/bin/env bash

function main() {
  echo "### Ok let's go !"

  # Install every repository package in one transaction. https://docs.docker.com/engine/install/linux-postinstall/
  sudo pacman -S --needed \
    docker docker-buildx docker-compose dockerfile-language-server docker-machine net-tools \
    greetd greetd-tuigreet \
    mise eza zip bat jq fzf buildkit tree-sitter tree-sitter-cli \
    mangowm hypridle gtklock ghostty dolphin dunst libnotify \
    awww bemenu bemenu-wayland brightnessctl playerctl wlopm \
    grim slurp satty wl-clipboard cliphist wtype \
    wireplumber pipewire pipewire-pulse libpulse pavucontrol pamixer easyeffects \
    networkmanager network-manager-applet power-profiles-daemon upower \
    blueman bluez bluez-utils fcitx5 fcitx5-gtk \
    kwallet kwalletmanager polkit-kde-agent nextcloud-client keepassxc \
    ddcutil ddcui libqalculate rofi-emoji btop pacman-contrib \
    ttf-jetbrains-mono-nerd noto-fonts-emoji steam discord teamspeak3 \
    base-devel cmake qt6-declarative codebook-lsp nvim zsh
  yay -S --needed \
    eww groovy-language-server-git dprint-bin lua-language-server pyright \
    wleave wayfreeze waycal

  # after nvim install run that
  # :Lazy build telescope-fzf-native.nvim
  echo "### Build telescope-fzf-native"
  nvim --headless '+Lazy build telescope-fzf-native.nvim' '+qa'

  echo "### Set the minifuse card to pro"
  card=$(pactl list cards short | awk 'tolower($0) ~ /arturia_minifuse_1/ { print $1; exit }')
  if [[ -n "$card" ]]; then
    pactl set-card-profile "$card" pro-audio && echo "### Audio card $card set to pro-audio"
  else
    echo "!!! No audio card found"
  fi

  echo "### Setting up omz"
  chsh -s "$(which zsh)"
  echo $SHELL

  echo "### Setting up sdkman"
  curl -s "https://get.sdkman.io" | zsh
  source /home/a2n/.zshrc
  sdk install java

  echo "### Setting up mise"
  curl -fsSL https://mise.run/zsh | sh
  source /home/a2n/.zshrc
  mise use --global node@lts
  mise use --global yarn@latest pnpm@latest

  echo "### Setting up some lsp (via npm)"
  npm install -g bash-language-server emmet-ls bash-language-server \
    vscode-langservers-extracted @olrtg/emmet-language-server svelte-language-server \
    gh-actions-language-server typescript typescript-language-server

  echo "### You still need to do: https://docs.docker.com/engine/install/linux-postinstall/"
}

read -r -p "Installing all the shit you need to keep telling people that linux is lightway? [y/N] " answer
if [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  main
else
  echo "Yeah sure... Bye."
fi

