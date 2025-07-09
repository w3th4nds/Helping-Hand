sudo apt update
sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen libuv1-dev

rm -rf ~/neovim-src
git clone https://github.com/neovim/neovim.git ~/neovim-src
cd ~/neovim-src
make CMAKE_BUILD_TYPE=Release
sudo make install
