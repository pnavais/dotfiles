-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>,", ":w<CR>", { desc = "Saves on double leader combo", noremap = true, silent = true })
map("n", "<leader>q", ":wq<CR>", { desc = "Saves and quits current buffer", noremap = true, silent = true })
map("n", "<leader>z", ":qa!<CR>", { desc = "Saves and quits current buffer", noremap = true, silent = true })
map("n", "<leader>cc", ":set cursorline!<CR>", { desc = "Toggles cursorline", noremap = true, silent = true })

-- Beginning of line
map("n", "<C-a>", "^", { desc = "Go to first non-blank character of line" })
map("i", "<C-a>", "<C-o>^", { desc = "Go to first non-blank character of line" })
map("v", "<C-a>", "^", { desc = "Go to first non-blank character of line" })

-- End of line
map("n", "<C-e>", "$", { desc = "Go to end of line" })
map("i", "<C-e>", "<C-o>$", { desc = "Go to end of line" })
map("v", "<C-e>", "$", { desc = "Go to end of line" })

-- Switch to next buffer with Tab
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Switch to previous buffer with Shift-Tab
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
