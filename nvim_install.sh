#!/bin/bash

# Function to uninstall Neovim and remove all related files
purge_neovim() {
    echo "Purging Neovim and its configuration..."
    
    # Remove Neovim package
    sudo apt remove --purge -y neovim

    # Remove Neovim config and data directories
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.cache/nvim

    echo "Neovim and all related configurations have been removed."
}

# Function to install Neovim
install_neovim() {
    echo "Installing Neovim..."
    
    # Add Neovim PPA for Ubuntu/Debian-based systems (skip for Arch, MacOS, Windows)
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt update
    sudo apt install -y neovim

    echo "Neovim installed successfully!"
}

# Function to install packer.nvim plugin manager
install_packer() {
    echo "Installing packer.nvim..."
    
    # Install packer.nvim plugin manager
    git clone --depth 1 https://github.com/wbthomason/packer.nvim \
      ~/.local/share/nvim/site/pack/packer/start/packer.nvim

    echo "packer.nvim installed successfully!"
}

# Function to install necessary language servers
install_language_servers() {
    echo "Installing language servers..."

    # Install clangd for C/C++
    sudo apt install -y clangd

    # Install pyright for Python
    sudo npm install -g pyright

    # Install intelephense for PHP
    sudo npm install -g intelephense

    echo "Language servers installed: clangd (C/C++), pyright (Python), intelephense (PHP)"
}

# Function to set up init.lua with autocompletion (for C/C++, Python, PHP), LSP, and custom settings
setup_nvim_config() {
    echo "Setting up Neovim configuration with autocompletion for C/C++, Python, and PHP, Tokyo Night theme (night variant), and custom settings..."
    
    # Create Neovim config directory
    mkdir -p ~/.config/nvim

    # Add Neovim configuration to init.lua
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

-- Load and initialize packer
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Packer manages itself

  -- Add Tokyo Night theme
  use 'folke/tokyonight.nvim'

  -- Autocompletion plugins
  use 'hrsh7th/nvim-cmp'  -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'  -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip'  -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'  -- Snippet completion source

  -- LSP plugins
  use 'neovim/nvim-lspconfig'  -- Collection of configurations for built-in LSP

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Setup nvim-cmp for autocompletion
local cmp = require'cmp'
local luasnip = require'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Accept completion
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },  -- LSP completions
    { name = 'luasnip' },  -- Snippet completions
  })
})

-- LSP configurations for C/C++, Python, and PHP
local lspconfig = require'lspconfig'

-- clangd for C/C++
lspconfig.clangd.setup{
  filetypes = { "c", "cpp", "objc", "objcpp" },
  on_attach = function(_, bufnr)
    print("clangd attached to buffer: " .. bufnr)
  end
}

-- pyright for Python
lspconfig.pyright.setup{
  on_attach = function(_, bufnr)
    print("pyright attached to buffer: " .. bufnr)
  end
}

-- intelephense for PHP
lspconfig.intelephense.setup{
  on_attach = function(_, bufnr)
    print("intelephense attached to buffer: " .. bufnr)
  end
}

-- Optional: Set line numbers and tab width
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Apply Tokyo Night theme
vim.cmd[[colorscheme tokyonight]]

EOF

    echo "Neovim configuration set up!"
}

# Function to install Tokyo Night theme and autocompletion using Packer
install_theme_and_autocomplete() {
    echo "Installing Tokyo Night theme and autocompletion plugins..."
    
    # Launch Neovim and run PackerSync to install the theme and autocompletion plugins
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

    echo "Tokyo Night theme and autocompletion plugins installed!"
}

# Main function to handle the process
main() {
    purge_neovim
    install_neovim
    install_packer
    install_language_servers  # Install language servers for C/C++, Python, PHP
    setup_nvim_config
    install_theme_and_autocomplete

    echo "Neovim installation with Tokyo Night theme, autocompletion for C/C++, Python, and PHP is complete!"
}

# Run the main function
main
