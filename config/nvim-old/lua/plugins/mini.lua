return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.surround").setup()
		require("mini.move").setup({
			mappings = {
				-- Move current line in Normal mode
				line_left = "<A-h>",
				line_right = "<A-l>",
				line_down = "<A-j>",
				line_up = "<A-k>",
				-- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
				left = "<A-h>",
				right = "<A-l>",
				down = "<A-j>",
				up = "<A-k>",
			},
			-- Options which control moving behavior
			options = {
				-- Automatically reindent selection during linewise vertical move
				reindent_linewise = true,
			},
		})
	end,
}
