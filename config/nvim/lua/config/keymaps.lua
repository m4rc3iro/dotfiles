-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("i", "jj", "<ESC>", { noremap = false })

-- Searches
vim.api.nvim_set_keymap(
  "n",
  "<leader>os",
  ':Telescope find_files search_dirs={"/Users/mae/obsidian"}<cr>',
  { noremap = false }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>og",
  ':Telescope live_grep search_dirs={"/Users/mae/obsidian"}<cr>',
  { noremap = false }
)
