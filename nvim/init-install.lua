--  ____             _           _ _   _   _                 _
-- |  _ \ __ _ _   _| |__   __ _| | | | \ | | ___  _____   _(_)_ __ ___
-- | |_) / _` | | | | '_ \ / _` | | | |  \| |/ _ \/ _ \ \ / / | '_ ` _ \
-- |  __/ (_| | |_| | |_) | (_| | | | | |\  |  __/ (_) \ V /| | | | | | |
-- |_|   \__,_|\__, |_.__/ \__,_|_|_| |_| \_|\___|\___/ \_/ |_|_| |_| |_|
--             |___/

-- Payball's Neovim configuration
-- ------------------------------

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
