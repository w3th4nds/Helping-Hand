#!/usr/bin/env bash

set -e

# Install dependencies
sudo apt update
sudo apt install -y \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
  libuv1-dev

# Remove existing Neovim if any
sudo rm -rf /usr/local/bin/nvim /usr/local/share/nvim

# Clone and build Neovim from source
git clone https://github.com/neovim/neovim.git ~/neovim-src
cd ~/neovim-src
make CMAKE_BUILD_TYPE=Release
sudo make install

# Confirm version and presence of uv
echo "Neovim version:"
nvim --version
echo "Testing uv availability:"
nvim --headless +"lua print(vim.loop)" +qall

