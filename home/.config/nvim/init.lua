local api = vim.api
local fn = vim.fn
local opt = vim.opt
local g = vim.g
local keymap = vim.keymap

-- plugins
vim.cmd [[packadd packer.nvim]]
require("packer").startup(function(use)
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons' }
  use "ms-jpq/coq_nvim"
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  use "lewis6991/gitsigns.nvim"
  use { "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } }
  use "wbthomason/packer.nvim"
  use "terrortylor/nvim-comment"
  use "neovim/nvim-lspconfig"
  use "nvim-treesitter/nvim-treesitter"
  use "kyazdani42/nvim-tree.lua"
  use "alexghergh/nvim-tmux-navigation"
  use { "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" }
  use "folke/tokyonight.nvim"
end)


-- options
keymap.set("n", "<SPACE>", "<Nop>")
g.mapleader = " "
opt.cmdheight = 1                           -- more space in the neovim command line for displaying messages
opt.conceallevel = 0                        -- so that `` is visible in markdown files
opt.cursorline = true                       -- highlight the current line
opt.expandtab = true                        -- convert tabs to spaces
opt.fileencoding = "utf-8"                  -- the encoding written to a file
opt.hlsearch = true                         -- highlight all matches on previous search pattern
opt.ignorecase = true                       -- ignore case in search patterns
opt.pumheight = 10                          -- pop up menu height
opt.shiftwidth = 2                          -- the number of spaces inserted for each indentation
opt.tabstop = 2                             -- insert 2 spaces for a tab
opt.laststatus = 3
opt.mouse = ""                              -- disable mouse
opt.number = true                           -- set numbered lines
opt.numberwidth = 4                         -- set number column width to 2 {default 4}
opt.ruler = false
opt.scrolloff = 8                           -- is one of my fav
opt.showcmd = false
opt.signcolumn = "yes"                      -- always show the sign column, otherwise it would shift the text each time
opt.showmode = false                        -- we don"t need to see things like -- INSERT -- anymore
opt.showtabline = 0                         -- always show tabs
opt.smartcase = true                        -- smart case
opt.smartindent = true                      -- make indenting smarter again
opt.splitbelow = true                       -- force all horizontal splits to go below current window
opt.splitright = true                       -- force all vertical splits to go to the right of current window
opt.termguicolors = true                    -- set term gui colors (most terminals support this)
opt.timeoutlen = 1000                       -- time to wait for a mapped sequence to complete (in milliseconds)
opt.undofile = true                         -- enable persistent undo
opt.updatetime = 300                        -- faster completion (4000ms default)
opt.shortmess:append "c"
opt.wrap = false                            -- display lines as one long line

local python_path = fn.expand("~/.pyenv/versions/vim/bin/python")
if fn.filereadable(python_path) == 1 then
  g.python3_host_prog = python_path
end

local PLUGINS_INSTALLED, _ = pcall(require, "coq")


-- plugins
g.coq_settings = {
  auto_start = 'shut-up',
  keymap = { recommended = false },
  clients = {
    tmux = { enabled = false },
    snippets = {
      warn = {}
    },
  },
}
if PLUGINS_INSTALLED then
  require("bufferline").setup {}
  require("coq")
  require("gitsigns").setup {}
  require("lualine").setup {}
  require("telescope").setup {
    defaults = {
      file_ignore_patterns = { ".git", "node_modules" }
    }
  }
  require("nvim_comment").setup {}
  require("nvim-treesitter").setup {}
  require("nvim-tree").setup {}
  require("nvim-tmux-navigation").setup {
    keybindings = {
      left = "<C-h>",
      down = "<C-j>",
      up = "<C-k>",
      right = "<C-l>",
    }
  }
end


-- functions
function toggleSidebar()
  if opt.number:get() then
    opt.signcolumn = "no" 
    opt.number = false
  else
    opt.signcolumn = "yes"
    opt.number = true
  end
end


-- theme
vim.cmd[[colorscheme tokyonight-night]]


-- shortcuts
keymap.set("n", "<leader>.", ":e ~/.config/nvim/init.lua<cr>")
keymap.set("n", "<leader>n", toggleSidebar)
keymap.set("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>")
keymap.set("n", "<leader>h", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
keymap.set("",  "<C-_>", ":CommentToggle<cr>")
keymap.set("n", "<C-b>", ":NvimTreeToggle<cr>")
keymap.set("n", "<C-p>", "<cmd>lua require('telescope.builtin').find_files({ hidden = true })<cr>")
keymap.set("n", "<C-f>", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
keymap.set("", "<C-x>", "\"_dd")
keymap.set("",  "<A-k>", ":m -2<cr>")
keymap.set("",  "<A-Left>", ":bprevious<cr>")
keymap.set("",  "<A-Right>", ":bnext<cr>")
keymap.set("",  "<C-w>", ":bd<cr>")
keymap.set("n", "<A-z>", ":set wrap!<cr>")


-- LSP shortcuts
if PLUGINS_INSTALLED then
  local on_lsp_attach = function(client, bufnr)
    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader><space>', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  end
  require("lspconfig").pyright.setup {
    on_attach = on_lsp_attach,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "off"
        }
      }
    }
  }
end
