return {
	{
		"cormacrelf/dark-notify",
		config = function()
			require("dark_notify").run({
				schemes = {
					dark = "cyberdream",
					light = {
						colorscheme = "cyberdream-light",
					},
				},
			})
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "auto", section_separators = "", component_separators = "" },
				sections = {
					lualine_a = { "mode" },
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "filetype" },
					lualine_y = {},
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts_extend = { "spec" },
		opts = {
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader>f", group = "file/find" },
					{ "<leader>s", group = "search" },
					{
						"<leader>b",
						group = "buffer",
						proxy = "<c-b>",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{
						"<leader>w",
						group = "windows",
						proxy = "<c-w>",
						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
				},
				{
					mode = { "n" },
					{ "<leader>bp", "<cmd>bprevvious<cr>", desc = "Prev Buffer" },
					{ "<leader>bn", "<cmd>bnext<cr>", desc = "Next Buffer" },
					{ "<leader>bb", "<cmd>e #<cr>", desc = "Switch to Other Buffer" },
					{ "<leader>bd", "<cmd>bd<cr>", desc = "Delete Buffer" },
				},
			},
		},
	},
	{
		"uga-rosa/ccc.nvim",
		ft = colored_fts,
		cmd = "CccPick",
		opts = function()
			local ccc = require("ccc")

			ccc.output.hex.setup({ uppercase = true })
			ccc.output.hex_short.setup({ uppercase = true })

			return {
				highlighter = {
					auto_enable = true,
					lsp = false,
				},
			}
		end,
	},
}
