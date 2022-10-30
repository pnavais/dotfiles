--  ____             _           _ _   _   _                 _
-- |  _ \ __ _ _   _| |__   __ _| | | | \ | | ___  _____   _(_)_ __ ___
-- | |_) / _` | | | | '_ \ / _` | | | |  \| |/ _ \/ _ \ \ / / | '_ ` _ \
-- |  __/ (_| | |_| | |_) | (_| | | | | |\  |  __/ (_) \ V /| | | | | | |
-- |_|   \__,_|\__, |_.__/ \__,_|_|_| |_| \_|\___|\___/ \_/ |_|_| |_| |_|
--             |___/

-- Payball's Neovim configuration
-- ------------------------------

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Packer configuration
vim.cmd([[packadd packer.nvim]])
require("packer").startup(function()
	use("wbthomason/packer.nvim")
	use("morhetz/gruvbox")
	use("nvim-treesitter/nvim-treesitter")
	use("junegunn/fzf")
	use("junegunn/fzf.vim")
	use("NoahTheDuke/vim-just")
	use("adelarsq/vim-matchit")
	use("tpope/vim-endwise")
	use("tpope/vim-repeat")
	use("preservim/nerdcommenter")
	use("Raimondi/delimitMate")
	use("godlygeek/tabular")
	use("nvim-tree/nvim-web-devicons")
	use("nvim-lualine/lualine.nvim")
	use("nvim-tree/nvim-tree.lua")
	use({"akinsho/bufferline.nvim", tag = "v3.*"})
end)

-- Treesitter configuration
require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "rust" },
	highlight = {
		enable = true,
	},
})

-- Lualine configuration
require("lualine").setup({
	options = {
		theme = "gruvbox",
		icons_enabled = true,
	},
})

-- Nvim tree configuration
require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
	adaptive_size = true,
	mappings = {
	    list = {
		{ key = "u", action = "dir_up" },
	    },
	},
    },
    renderer = {
	group_empty = true,
    },
    filters = {
	dotfiles = true,
    },
})

-- Bufferline configuration
require("bufferline").setup({})

vim.cmd([[colorscheme gruvbox]])   -- Set color scheme

vim.opt.number = true              -- Show line numbers
vim.opt.list = true                -- Show invisible characters
vim.opt.listchars:append("tab:> ") -- Remap invisible characters
vim.opt.shiftwidth = 4             -- Number of spaces to use for indent and unindent
vim.opt.softtabstop = 4            -- Edit as if the tabs are 4 characters wide
vim.opt.shiftround = true          -- Round indent to a multiple of shiftwidth
vim.opt.smartindent = true         -- Do smart autoindenting when starting a new line
vim.opt.expandtab = false          -- Keep tabs
vim.opt.cursorline = true          -- Show cursor line
vim.opt.cursorcolumn = false       -- Show cursor line vertically
vim.opt.swapfile = false           -- Disable swap file
vim.opt.ignorecase = true          -- Always case insensitive
vim.opt.smartcase = true           -- Override ignorecase option if the search pattern contains upper case characters
vim.opt.termguicolors = true       -- Enables 24-bit RGB color in the Terminal UI
vim.opt.wildignorecase = true      -- Case insensitive for file names and directories completion
vim.opt.pastetoggle = "<F2>"       -- Toggle paste mode
vim.opt.wildmenu = true            -- enables wild menu
vim.opt.wildmode = "list:longest"  -- When more than one match, list all matches and complete till longest common string 

-- Leader key
vim.g.mapleader = ","

-- Remaps
vim.api.nvim_set_keymap("n", "<leader>,", ":w<CR>", { noremap = false })                               -- Quick save
vim.api.nvim_set_keymap("n", "<leader>q", ":wq<CR>", { noremap = false })                              -- Exit saving
vim.api.nvim_set_keymap("n", "<leader>x", ":q!<CR>", { noremap = false })                              -- Exit without saving
vim.api.nvim_set_keymap("n", "<leader>sv", ":source $MYVIMRC<CR>", { silent = true, noremap = false }) -- Reload config
vim.api.nvim_set_keymap("n", "<leader>ev", ":vsplit $MYVIMRC<CR>", { silent = true, noremap = false }) -- Open config
vim.api.nvim_set_keymap("n", "<CR>", ":nohlsearch<CR>", { silent = true, noremap = true })             -- Hide highlighted matches after search
vim.api.nvim_set_keymap("n", "<leader>n" , ":bp<CR>", { silent = true, noremap = true })               -- Show previous buffer
vim.api.nvim_set_keymap("n", "<leader>m" , ":bn<CR>", { silent = true, noremap = true })               -- Show next buffer
vim.api.nvim_set_keymap("n", "<leader>fr", ":History<CR>", { noremap = true })                         -- Show recently used files (FZF)
vim.api.nvim_set_keymap("n", "<leader>f", ":FZF<CR>", { noremap = true })                              -- Show recently used files (FZF)
vim.api.nvim_set_keymap("n", "<c-n>", ":NvimTreeToggle<CR>", { silent = true, noremap = true })        -- Open nvim tree
vim.api.nvim_set_keymap("n", "<leader>wc", ":wincmd q<CR>", {  noremap = true })                      -- Close window

-- File associations
vim.cmd([[autocmd BufRead,BufNewFile *.conf,*.cfg,*.tl setlocal filetype=toml]])
