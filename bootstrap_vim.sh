#!/bin/bash
set -euo pipefail -o errtrace

SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

backup_original() {
  if [ -f "$1" ] || [ -d "$1" ]; then
    if [ -L "$1" ]; then
      rm "$1"
    else
      mv "$1" "$1.bak"
    fi
  fi
}

detect_arch() {
  local arch=""
  if command -v dpkg >/dev/null 2>&1; then
    arch=$(dpkg --print-architecture || true)
  fi
  if [ -z "${arch:-}" ]; then
    case "$(uname -m)" in
      x86_64) arch="amd64" ;;
      aarch64|arm64) arch="arm64" ;;
      *) arch="$(uname -m)";;
    esac
  fi
  echo "$arch"
}

ARCH="$(detect_arch)"
echo "Detected architecture: ${ARCH}"

mkdir -p ~/scratch
cd ~/scratch

# tmux
backup_original ~/.tmux.conf
ln -s "$SCRIPT_PATH/home/.tmux.conf" ~/.tmux.conf

# neovim
echo "Installing neovim..."
backup_original ~/.config/nvim/init.lua
mkdir -p ~/.config/nvim

if [ "${ARCH}" = "amd64" ]; then
  rm -f nvim-linux-x86_64.deb
  wget -q https://github.com/neovim/neovim-releases/releases/download/stable/nvim-linux-x86_64.deb
  sudo apt-get update -y
  sudo dpkg -i nvim-linux-x86_64.deb
  rm -f nvim-linux-x86_64.deb
  NVIM_BIN="$(command -v nvim)"
elif [ "${ARCH}" = "arm64" ]; then
  # Use official arm64 tarball
  rm -f nvim-linux-arm64.tar.gz || true
  if ! wget -q https://github.com/neovim/neovim/releases/download/stable/nvim-linux-arm64.tar.gz; then
    wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
  fi
  sudo rm -rf /usr/local/nvim
  sudo tar xzf nvim-linux-arm64.tar.gz -C /usr/local
  sudo mv /usr/local/nvim-linux-* /usr/local/nvim
  sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
  NVIM_BIN="/usr/local/bin/nvim"
  rm -f nvim-linux-arm64.tar.gz
else
  echo "Unsupported architecture for this setup: ${ARCH}"
  exit 1
fi

ln -s "$SCRIPT_PATH/home/.config/nvim/init.lua" ~/.config/nvim/init.lua || true

# packer.nvim
if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi

# set alternatives
sudo update-alternatives --install /usr/bin/vi vi "${NVIM_BIN}" 70
sudo update-alternatives --install /usr/bin/vim vim "${NVIM_BIN}" 70
sudo update-alternatives --install /usr/bin/editor editor "${NVIM_BIN}" 70

# headless plugin sync (ignore failures)
"${NVIM_BIN}" --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || true

# Node.js (works on amd64/arm64)
if ! command -v npm >/dev/null 2>&1; then
  echo "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash -
  sudo apt-get install -y nodejs
fi

# pyright
sudo npm install -g pyright

# ripgrep
echo "Installing ripgrep 15.1.0 (.deb)..."
RG_VERSION="15.1.0"
case "${ARCH}" in
  amd64)
    RG_DEB="ripgrep_${RG_VERSION}-1_amd64.deb"
    ;;
  arm64)
    RG_DEB="ripgrep_${RG_VERSION}-1_arm64.deb"
    ;;
  *)
    echo "Unsupported architecture for ripgrep .deb: ${ARCH}"
    exit 1
    ;;
esac

rm -f "${RG_DEB}" || true
wget -q "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${RG_DEB}"
sudo dpkg -i "${RG_DEB}" || sudo apt-get -f install -y
rm -f "${RG_DEB}"

if [ -z "${RCALL_JOB_NAME:-}" ]; then
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt-get update
  sudo apt-get install -y git
  if command -v git &> /dev/null; then
    git config --global user.useConfigOnly true
  fi
fi

echo "Done."

