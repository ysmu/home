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
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.deb 2> /dev/null
sudo dpkg -i nvim-linux64.deb > /dev/null 2>&1
rm nvim-linux64.deb
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
backup_original ~/.config/nvim/init.lua
mkdir -p ~/.config/nvim
ln -s "$SCRIPT_PATH/home/.config/nvim/init.lua" ~/.config/nvim/init.lua
if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'


# git
if command -v git &> /dev/null; then
  git config --global user.useConfigOnly true
fi

