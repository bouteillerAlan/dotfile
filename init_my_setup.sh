#!/bin/zsh
echo "Launch."

RED='\033[0;31m'
NOCOLOR='\033[0m'

# try if zsh exist if not send error
if [ "${SHELL##*/}" != 'zsh' ]; then
  echo -e "${RED}You need to install zsh first and launch this script with it.${NOCOLOR}" >&2
  exit 1
fi

echo -e "${RED}Launch package install.${NOCOLOR}"
# init core package
yay -S bpytop docker docker-compose eza kitty kleopatra neovim neofetch tldr tree zoxide dracut-numlock

# init core gui
yay -S keepassxc nextcloud-client obs-studio obsidian signal-desktop spotify-launcher flameshot

# init extra package
yay -S kdeplasma-blurredwallpaper-git kdeplasma-arch-update-notifier-git lolcat noto-fonts noto-fonts-emoji noto-fonts-extra noto-fonts-cjk ttf-noto-nerd screenfetch

echo -e "${RED}Setup docker.${NOCOLOR}"
# post config for docker
echo -e "${RED}Setup grp.${NOCOLOR}"
sudo groupadd -f docker # -f is here because in most of the case the cmd failed bcs the group already exist
echo -e "${RED}Setup usermod.${NOCOLOR}"
sudo usermod -aG docker $USER
echo -e "${RED}Refresh grp.${NOCOLOR}"
#newgrp docker
echo -e "${RED}start docker.${NOCOLOR}"
sudo systemctl start docker
echo -e "${RED}Test docker.${NOCOLOR}"
docker run hello-world
echo -e "${RED}stop docker.${NOCOLOR}"
sudo systemctl stop docker.socket
sudo systemctl stop docker

echo -e "${RED}Init git.${NOCOLOR}"
# init git
git config --global commit.gpgsign true
git config --global user.signingkey "6A2ECC8A396F8A943A109A1E0F11C2A6BF79111E"
git config --global user.name "Bouteiller [a2n] Alan"
git config --global user.email "a2n.dev@pm.me"
git config --global init.defaultBranch main

echo -e "${RED}Install zsh and plugins.${NOCOLOR}"
# delete old install if present
rm -rf ~/.oh-my-zsh
# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# install default tool or tool plugins
## zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
## zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
## copy config file
mv ~/.zshrc ~/.zshrc.post-a2n.bak
cp .zshrc ~/.zshrc

echo -e "${RED}Install volta.${NOCOLOR}"
## volta for node management
curl https://get.volta.sh | zsh
source ~/.zshrc
volta install node
volta install yarn

echo -e "${RED}Setup host and host.deny.${NOCOLOR}"
# host deny config
sudo wget https://hosts.ubuntu101.co.za/superhosts.deny -O /etc/hosts.deny
sudo mv /etc/hosts /etc/hosts.bak
sudo wget https://hosts.ubuntu101.co.za/hosts -O /etc/hosts

echo -e "${RED}Setup kitty.${NOCOLOR}"
# setup kitty
mv kitty ~/.config/
kitty +runpy 'from kitty.config import *; print(commented_out_default_config())' > ~/.config/kitty/kitty.conf
echo "include frappe.conf" | tee -a ~/.config/kitty/kitty.conf

echo -e "${RED}Config nvim.${NOCOLOR}"
# setup nvim
mv nvim ~/.config/
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# ssh
mkdir ~/.ssh

echo -e "${RED}////////////////////////////////////"
echo -e "Don't forget to import your gpg/ssh key."
echo -e "Don't forget to do in nvim :"
echo -e " - PackerSync"
echo -e " - PackerUpdate"
echo -e "////////////////////////////////////${NOCOLOR}"

exit 0
