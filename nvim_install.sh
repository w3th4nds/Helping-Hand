#!/usr/bin/env bash

set -e

NEOVIM_SRC_DIR="$HOME/neovim-src"
NEOVIM_BIN="/usr/local/bin/nvim"

# Check for --force flag
FORCE=0
if [ "$1" == "--force" ]; then
  FORCE=1
fi

# Check if Neovim is already installed
if [ $FORCE -eq 0 ] && command -v nvim >/dev/null 2>&1; then
  echo "✅ Neovim already installed at $NEOVIM_BIN."
  echo "👉 Use './install_neovim.sh --force' to rebuild from source."
  exit 0
fi

echo "🔧 Installing Neovim from source..."

# Install build dependencies
sudo apt update
sudo apt install -y \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen libuv1-dev

# Clean old source if exists
rm -rf "$NEOVIM_SRC_DIR"

# Clone and build Neovim
git clone https://github.com/neovim/neovim.git "$NEOVIM_SRC_DIR"
cd "$NEOVIM_SRC_DIR"
make CMAKE_BUILD_TYPE=Release
sudo make install

# Confirm installation
echo "✅ Neovim installed successfully:"
nvim --version | head -n 1

