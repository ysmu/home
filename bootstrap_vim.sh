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
wget https://github.com/neovim/neovim-releases/releases/download/stable/nvim-linux-x86_64.deb
sudo dpkg -i nvim-linux-x86_64.deb
sudo update-alternatives --install /usr/bin/vi vi "$(which nvim)" 70
sudo update-alternatives --install /usr/bin/vim vim "$(which nvim)" 70
sudo update-alternatives --install /usr/bin/editor editor "$(which nvim)" 70
backup_original ~/.config/nvim/init.lua
mkdir -p ~/.config/nvim
ln -s "$SCRIPT_PATH/home/.config/nvim/init.lua" ~/.config/nvim/init.lua
if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'


# Install node
if ! command -v npm &> /dev/null; then
  echo "Installing node..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash - &&\
  sudo apt-get install -y nodejs
fi


# pyright
sudo npm install -g pyright


# rg
rm -rf ripgrep_13.0.0_amd64.deb
wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb 2> /dev/null
sudo dpkg -i ripgrep_13.0.0_amd64.deb > /dev/null 2>&1
rm -rf ripgrep_13.0.0_amd64.deb


# git - not available on work machine
if [ -z "$RCALL_JOB_NAME" ]; then
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt update
  sudo apt install -y git
  if command -v git &> /dev/null; then
    git config --global user.useConfigOnly true
  fi
fi
