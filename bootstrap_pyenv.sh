#!/bin/bash
set -euo pipefail -o errtrace

SCRIPT=$(realpath "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

source "$SCRIPT_PATH/utils.sh"

echo "Bootstrapping pyenv..."

# https://github.com/pyenv/pyenv/wiki
sudo apt-get update > /dev/null
sudo apt-get install make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  > /dev/null

# https://github.com/pyenv/pyenv-installer#install
if [ ! -d ~/.pyenv ]; then
  echo "Running pyenv installer..."
  curl https://pyenv.run | bash
fi

addition='export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
'
add_to_bashrc "initialize pyenv" "$addition"

