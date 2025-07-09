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

