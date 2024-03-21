#!/bin/bash

# root has to run the script
if [[ $(id -u -n) != "root" ]]
    then
    printf "You need to be root to do this!\nIf you have SUDO installed, then run this script with `sudo ${0}`"
    exit 1
fi

echo "Launch package install."
# init core package
yay -S bpytop docker docker-compose eza kitty kleopatra neovim neofetch tldr tree zoxide zsh dracut-numlock

# init core gui
yay -S keepassxc nextcloud-client obs-studio obsidian signal-desktop spotify-launcher flameshot

# init extra package
yay -S kdeplasma-blurredwallpaper-git kdeplasma-arch-update-notifier-git lolcat noto-fonts noto-fonts-emoji noto-fonts-extra noto-fonts-cjk ttf-noto-nerd screenfetch

echo "Setup docker."
# post config for docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
echo "Test docker."
docker run hello-world

echo "Init git."
# init git
git config --global commit.gpgsign true
git config --global user.signingkey "6A2ECC8A396F8A943A109A1E0F11C2A6BF79111E"
git config --global user.name "Bouteiller [a2n] Alan"
git config --global user.email "a2n.dev@pm.me"
git config --global init.defaultBranch main

echo "Install zsh plugins."
# install default tool or tool plugins
## zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
## zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Install volta."
## volta for node management
curl https://get.volta.sh | zsh
source ~/.zshrc
volta install node
volta install yarn

echo "Setup host and host.deny."
# host deny config
sudo wget https://hosts.ubuntu101.co.za/superhosts.deny -O /etc/hosts.deny
sudo mv /etc/hosts /etc/hosts.bak
sudo wget https://hosts.ubuntu101.co.za/hosts -O /etc/hosts

echo "Setup kitty."
# setup kitty
mv ./kitty/* ~/.config/kitty/
kitty +runpy 'from kitty.config import *; print(commented_out_default_config())' > ~/.config/kitty/kitty.conf
echo "include frappe.conf" | tee -a ~/.config/kitty/kitty.conf

echo "Config nvim."
# setup nvim
mv ./nvim ~/.config/
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# ssh
mkdir ~/.ssh

echo "////////////////////////////////////"
echo "Don't forget to import your gpg/ssh key."
echo "Don't forget to do in nvim :"
echo " - PackerSync"
echo " - PackerUpdate"
echo "////////////////////////////////////"

exit 0
