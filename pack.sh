#! /usr/bin/sh

cd ~/Downloads/

# install base packages
sudo pacman -Syu && sudo pacman -S python zsh neovim btop kleopatra keepassxc ghostty discord signal-desktop gimp partitionmanager kooha meld nextcloud-client ttf-jetbrains-mono-nerd aws-cli-v2 zoxide tree && yay -S intellij-idea-ultimate-edition coppwr zen-browser

# install oh-my-zsh
chsh -s $(which zsh)
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# java sdk
curl -s "https://get.sdkman.io" | bash
sdk install java 21.0.6-ms

# volta
curl https://get.volta.sh | bash
volta install node

# go
curl https://go.dev/dl/go1.25.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.25.1.linux-amd64.tar.gz

