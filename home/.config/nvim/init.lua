local api = vim.api
local fn = vim.fn
local opt = vim.opt
local g = vim.g
local keymap = vim.keymap

-- plugins
vim.cmd [[packadd packer.nvim]]
require("packer").startup(function(use)
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons' }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  use "lewis6991/gitsigns.nvim"
  use { "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } }
  use "wbthomason/packer.nvim"
  use "terrortylor/nvim-comment"
  use "neovim/nvim-lspconfig"
  use { "L3MON4D3/LuaSnip", tag = "v<CurrentMajor>.*" }
  use "nvim-treesitter/nvim-treesitter"
  use "kyazdani42/nvim-tree.lua"
  use "alexghergh/nvim-tmux-navigation"
  use { "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" }
  use "folke/tokyonight.nvim"
  use { "hrsh7th/nvim-cmp", requires = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-nvim-lsp-signature-help" } }
end)


-- options
keymap.set("n", "<SPACE>", "<Nop>")
g.mapleader = " "
opt.cmdheight = 1                           -- more space in the neovim command line for displaying messages
opt.conceallevel = 0                        -- so that `` is visible in markdown files
opt.cursorline = true                       -- highlight the current line
opt.expandtab = true                        -- convert tabs to spaces
opt.fileencoding = "utf-8"                  -- the encoding written to a file
opt.formatoptions = "cq"                    -- No automatic wrapping
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
opt.textwidth = 120                         -- autowrapping is determined by formatoptions
opt.timeoutlen = 1000                       -- time to wait for a mapped sequence to complete (in milliseconds)
opt.undofile = true                         -- enable persistent undo
opt.updatetime = 300                        -- faster completion (4000ms default)
opt.shortmess:append "c"
opt.wrap = false                            -- display lines as one long line
opt.fillchars = opt.fillchars + "diff:/"    -- get diagonals instead of the default dash signs in diff views

local python_path = fn.expand("~/.pyenv/versions/vim/bin/python")
if fn.filereadable(python_path) == 1 then
  g.python3_host_prog = python_path
end

local PLUGINS_INSTALLED, _ = pcall(require, "bufferline")


-- plugins
if PLUGINS_INSTALLED then
  require("bufferline").setup {
    options = {
      diagnostics = "nvim_lsp",
      show_close_icon = false,
      show_buffer_close_icons = false,
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true
        }
      }
    }
  }
  require("diffview").setup {
    enhanced_diff_hl = true,
  }
  require("gitsigns").setup {
    current_line_blame_opts = {
      delay = 0,
    },
    on_attach = function()
      local gs = package.loaded.gitsigns

      keymap.set("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, {expr=true})

      keymap.set("n", "]c", function()
        if vim.wo.diff then return "c]" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, {expr=true})

      keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<cr>")
      keymap.set("n", "<leader>gg", function() gs.blame_line{ full=true } end)
      keymap.set("n", "tb", ":Gitsigns toggle_current_line_blame<cr>")
    end
  }
  require("lualine").setup {}
  require("telescope").setup {
    pickers = {
      find_files = {
        find_command = {"rg", "--files", "--hidden", "-g", "!.git"},
      }
    }
  }
  require("nvim_comment").setup {}
  -- Treesitter: use the correct configs module
  require("nvim-treesitter.configs").setup {}
  require("nvim-tree").setup {}
  require("nvim-tmux-navigation").setup {}  -- Don't setup keybindings here because they are bound to normal mode.
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
vim.cmd[[silent! colorscheme tokyonight-night]]


-- shortcuts
keymap.set("n", "<leader>.", ":e ~/.config/nvim/init.lua<cr>")
keymap.set("n", "tn", toggleSidebar)
keymap.set("n", "<leader>b", "<cmd>lua require('telescope.builtin').buffers()<cr>")
keymap.set("n", "<leader>h", "<cmd>lua require('telescope.builtin').help_tags()<cr>")
keymap.set("n", "<leader>w", ":NvimTreeFindFile<cr>")
keymap.set("",  "<C-_>", ":CommentToggle<cr>", { silent = true })
keymap.set("n", "<C-b>", ":NvimTreeToggle<cr>", { silent = true })
keymap.set("n", "<C-p>", "<cmd>lua require('telescope.builtin').find_files({ hidden = true })<cr>", { silent = true })
keymap.set("n", "<C-f>", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { silent = true })
keymap.set("",  "<C-x>", "\"_dd", { silent = true })
keymap.set("",  "<A-q>", "gq}", { silent = true })
keymap.set("",  "<A-k>", ":m -2<cr>", { silent = true })
keymap.set("",  "<A-Up>", ":move -2<cr>", { silent = true })
keymap.set("",  "<A-Down>", ":move +1<cr>", { silent = true })
keymap.set("",  "<A-Left>", ":bprevious<cr>", { silent = true })
keymap.set("",  "<A-Right>", ":bnext<cr>", { silent = true })
keymap.set("",  "<C-h>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>", { silent = true })
keymap.set("",  "<C-j>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>", { silent = true })
keymap.set("",  "<C-k>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>", { silent = true })
keymap.set("",  "<C-l>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>", { silent = true })
keymap.set("",  "<C-w>", ":b#<bar>bd#<cr>", { silent = true })
keymap.set("n", "<A-z>", ":set wrap!<cr>", { silent = true })
keymap.set("n", "<leader>gh", ":DiffviewFileHistory<cr>")
keymap.set("n", "<leader>gD", ":DiffviewOpen<cr>")
keymap.set("n", "<leader>gd", function()
  vim.cmd[[silent! DiffviewOpen -- %]]
  vim.cmd[[silent! DiffviewToggleFiles]]
end)


-- LSP
if PLUGINS_INSTALLED then
  local on_lsp_attach = function(client, bufnr)
    api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
    keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    keymap.set("n", "<leader><space>", vim.lsp.buf.hover, bufopts)
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  end

  local cmp = require("cmp")
  local cmp_select_opts = { behavior = cmp.SelectBehavior.Select }
  cmp.setup {
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    completion = {
      completeopt = 'menu, menuone, noinsert'
    },
    sources = {
      { name = "path" },
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "buffer", keyword_length = 3 },
    },
    window = {
      documentation = cmp.config.window.bordered()
    },
    formatting = {
      fields = {"menu", "abbr", "kind"},
    },
    mapping = {
      ["<Up>"] = cmp.mapping.select_prev_item(cmp_select_opts),
      ["<Down>"] = cmp.mapping.select_next_item(cmp_select_opts),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      end, {"i", "s"}),
      ["<cr>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      end, {"i", "s"}),
    },
  }

  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  vim.lsp.config("pyright", {
    capabilities = capabilities,
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
    },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  })

  vim.lsp.enable({ "pyright" })
end

