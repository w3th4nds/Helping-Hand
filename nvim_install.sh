#!/bin/bash

set -e

# Function to uninstall Neovim and remove all related files
purge_neovim() {
    echo "Purging Neovim and its configuration..."
    sudo apt remove --purge -y neovim
    rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
    echo "Neovim and all related configurations have been removed."
}

# Function to install Neovim
install_neovim() {
    echo "Installing Neovim..."
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt update
    sudo apt install -y neovim
    echo "Neovim installed successfully!"
}

# Function to install packer.nvim plugin manager
install_packer() {
    echo "Installing packer.nvim..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim \
      ~/.local/share/nvim/site/pack/packer/start/packer.nvim
    echo "packer.nvim installed successfully!"
}

# Function to install necessary language servers
install_language_servers() {
    echo "Installing language servers..."
    sudo apt install -y npm
    sudo apt install -y clangd
    sudo npm install -g pyright intelephense
    echo "Language servers installed: clangd (C/C++), pyright (Python), intelephense (PHP)"
}

# Function to set up init.lua with autocompletion, LSP, and theme
setup_nvim_config() {
    echo "Setting up Neovim configuration..."
    mkdir -p ~/.config/nvim
    cat <<EOF > ~/.config/nvim/init.lua
-- Auto-install packer if not already installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'folke/tokyonight.nvim'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'neovim/nvim-lspconfig'
  if packer_bootstrap then require('packer').sync() end
end)

-- Safe requires
local cmp_status, cmp = pcall(require, 'cmp')
if not cmp_status then return end
local luasnip_status, luasnip = pcall(require, 'luasnip')
if not luasnip_status then return end

cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  })
})

local lspconfig = require'lspconfig'

lspconfig.clangd.setup{}
lspconfig.pyright.setup{}
lspconfig.intelephense.setup{}

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.cmd[[colorscheme tokyonight]]
EOF
    echo "Neovim configuration set up!"
}

# Function to install plugins
install_theme_and_autocomplete() {
    echo "Installing Neovim plugins..."
    nvim --headless -c 'autocmd VimEnter * quitall'
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    echo "Plugins installed!"
}

main() {
    purge_neovim
    install_neovim
    install_packer
    install_language_servers
    setup_nvim_config
    install_theme_and_autocomplete
    echo "Neovim setup complete!"
}

main