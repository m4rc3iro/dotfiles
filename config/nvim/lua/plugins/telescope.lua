return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.6",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup({
			defaults = {
				layout_config = {
					vertical = { width = 0.2 },
					-- other layout configuration here
				},
				-- other defaults configuration here
			},
			pickers = {
				find_files = {
					-- follow = true, -- allows to find simlinked files
					hidden = true, -- allows to find hidden files
					file_ignore_patterns = {
						"%.pdf",
						"%.png",
						"%.jpeg",
						"%.jpg",
					},
					theme = "dropdown",
				},
				live_grep = {
					theme = "dropdown",
				},
			},
		})

		-- set keymaps
		local keymap = vim.keymap
		keymap.set("n", "<leader>fs", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find string in cwd" })
	end,
}
