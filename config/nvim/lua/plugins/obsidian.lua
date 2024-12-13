local function createNoteWithDefaultTemplate()
	local TEMPLATE_FILENAME = "default-note"
	local obsidian = require("obsidian").get_client()
	local utils = require("obsidian.util")

	-- prevent Obsidian.nvim from injecting it's own frontmatter table
	obsidian.opts.disable_frontmatter = true

	-- prompt for note title
	-- @see: borrowed from obsidian.command.new
	local note
	local title = utils.input("Enter title or path (optional): ")
	if not title then
		return
	elseif title == "" then
		title = nil
	end

	note = obsidian:create_note({ title = title, no_write = true })

	if not note then
		return
	end
	-- open new note in a buffer
	obsidian:open_note(note, { sync = true })
	-- NOTE: make sure the template folder is configured in Obsidian.nvim opts
	obsidian:write_note_to_buffer(note, { template = TEMPLATE_FILENAME })
	-- hack: delete empty lines before frontmatter; template seems to be injected at line 2
	vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
end

return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = false,
	ft = "markdown",

	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},

	init = function()
		vim.opt.conceallevel = 2
		--
		-- convert note to template and remove leading white space
		vim.keymap.set("n", "<leader>on", ":ObsidianNewFromTemplate<cr>")
		vim.keymap.set("n", "<leader>ot", ":ObsidianTemplate default-note<cr>")
		-- vim.keymap.set("n", "<leader>on", createNoteWithDefaultTemplate, { desc = "[N]ew Obsidian [N]ote" })
		--
		-- search for files in full vault
		vim.keymap.set("n", "<leader>os", ':Telescope find_files search_dirs={"/home/mae/obsidian"}<cr>')
		vim.keymap.set("n", "<leader>og", ':Telescope live_grep search_dirs={"/home/mae/obsidian"}<cr>')
	end,

	opts = {
		workspaces = {
			{
				name = "obsidian",
				path = "~/obsidian",
			},
		},
		-- Optional, if you keep notes in a specific subdirectory of your vault.
		notes_subdir = "atomic",
		-- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
		completion = {
			-- Set to false to disable completion.
			nvim_cmp = true,
			-- Trigger completion at 2 chars.
			min_chars = 2,
		},
		new_notes_location = "notes_subdir",
		disable_frontmatter = true,
		mappings = {
			-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
		},

		-- Templates config
		templates = {
			folder = "~/obsidian/_templates",
			date_format = "%d-%m-%Y",
			time_format = "%H:%M",
			-- A map for custom variables, the key should be the variable and the value a function
			substitutions = {},
		},
		-- Specify how to handle attachments.
		attachments = {
			img_folder = "~/obsidian/_assets", -- This is the default
		},
		ui = {
			enable = true, -- set to false to disable all additional syntax features
			update_debounce = 200, -- update delay after a text change (in milliseconds)
			checkboxes = {
				-- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
				[" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
				["x"] = { char = "", hl_group = "ObsidianDone" },
				[">"] = { char = "", hl_group = "ObsidianRightArrow" },
				["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
			},
			external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			-- Replace the above with this if you don't have a patched font:
			-- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
			reference_text = { hl_group = "ObsidianRefText" },
			highlight_text = { hl_group = "ObsidianHighlightText" },
			tags = { hl_group = "ObsidianTag" },
			hl_groups = {
				-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
				ObsidianTodo = { bold = true, fg = "#f78c6c" },
				ObsidianDone = { bold = true, fg = "#89ddff" },
				ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
				ObsidianTilde = { bold = true, fg = "#ff5370" },
				ObsidianRefText = { underline = true, fg = "#c792ea" },
				ObsidianExtLinkIcon = { fg = "#c792ea" },
				ObsidianTag = { italic = true, fg = "#89ddff" },
				ObsidianHighlightText = { bg = "#75662e" },
			},
		},
	},
}
