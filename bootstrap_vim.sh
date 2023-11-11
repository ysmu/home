#!/bin/bash
set -euo pipefail -o errtrace

SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")


function backup_original {
  if [ -f "$1" ] || [ -d "$1" ]; then
    if [ -L "$1" ]; then
      rm "$1"
    else
      mv "$1" "$1.bak"
    fi
  fi
}


mkdir -p ~/scratch
cd ~/scratch


# tmux
backup_original ~/.tmux.conf
ln -s "$SCRIPT_PATH/home/.tmux.conf" ~/.tmux.conf


# neovim
echo "Installing neovim..."
rm -f nvim-linux64.deb
wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod +x nvim.appimage
sudo mkdir -p /usr/local/bin
sudo mv nvim.appimage /usr/local/bin/nvim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 70
sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 70
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 70
backup_original ~/.config/nvim/init.lua
mkdir -p ~/.config/nvim
ln -s "$SCRIPT_PATH/home/.config/nvim/init.lua" ~/.config/nvim/init.lua
if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'


# Install node
echo "Installing node..."
sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update && sudo apt-get install nodejs -y 2>/dev/null


# pyright
sudo npm install -g pyright


# rg
rm -rf ripgrep_13.0.0_amd64.deb
wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb 2> /dev/null
sudo dpkg -i ripgrep_13.0.0_amd64.deb > /dev/null 2>&1
rm -rf ripgrep_13.0.0_amd64.deb


# git
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git
if command -v git &> /dev/null; then
  git config --global user.useConfigOnly true
fi

