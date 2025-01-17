vim.g.mapleader = " "

local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

-- Save
map("n", "<leader>s", "<CMD>update<CR>")

-- Quit
map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
map("i", "jj", "<ESC>")

-- NeoTree
map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
map("n", "<leader>r", "<CMD>Neotree focus<CR>")

-- minimap
map("n", "<leader>m", "<CMD>MinimapToggle<CR>")

-- New Windows
map("n", "<leader>d", "<CMD>vsplit<CR>")
map("n", "<leader><C-d>", "<CMD>split<CR>")

-- Window Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-j>", "<C-w>j")

-- Resize Windows
map("n", "<C-Right>", "<C-w><")
map("n", "<C-Left>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

-- Editor
map("n", "<S-d>", "20j") -- jump cursor down
map("n", "<S-u>", "20k") -- jump cursor up
map("n", "<C-d>", "d$") -- delete till end of line

-- Searches
map("n", "<leader>os", ':Telescope find_files search_dirs={"/home/mae/obsidian"}<cr>')
map("n", "<leader>og", ':Telescope live_grep search_dirs={"/home/mae/obsidian"}<cr>')
map(
	"n",
	"<leader>vs",
	':Telescope find_files search_dirs={"/home/mae/.config/nvim","/home/mae/.dotfiles/config/nvim"}<cr>'
)
map(
	"n",
	"<leader>vg",
	':Telescope live_grep search_dirs={"/home/mae/.config/nvim","/home/mae/.dotfiles/config/nvim"}<cr>'
)
