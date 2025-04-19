local colored_fts = {
	"cfg",
	"css",
	"conf",
	"lua",
	"scss",
}
return {
	{
		"scottmckendry/cyberdream.nvim",
		lazy = true,
		priority = 1000,
		init = function()
			vim.cmd.colorscheme("cyberdream")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "gruvbox_dark", section_separators = "", component_separators = "" },
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
					filetypes = colored_fts,
					lsp = false,
				},
			}
		end,
	},
}
