return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	{
		"L3MON4D3/LuaSnip",
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					local bufopts = function(desc)
						return { buffer = event.buf, desc = desc }
					end
					vim.keymap.set("n", "K", function()
						vim.lsp.buf.hover({ border = "single" })
					end, bufopts("Hover"))

					map("gd", require("telescope.builtin").lsp_definitions, "definitions")
					map("<leader>rn", vim.lsp.buf.rename, "rename")
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						return diagnostic.message
					end,
				},
			})

			require("mason").setup()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"gopls",
					"zls",
					"shfmt",
					"stylua",
					"prettier",
					"yaml-language-server",
					"typescript-language-server",
					"vue-language-server",
					"goimports",
					"gofumpt",
				},
			})

			-- vue
			local vue_ls_path = vim.fn.expand("$MASON/packages/vue-language-server")
			local vue_plugin_path = vue_ls_path .. "/node_modules/@vue/language-server"

			vim.lsp.enable({
				"gopls",
				"yamlls",
				"zls",
				"ts_ls",
			})
			vim.lsp.config("ts_ls", {
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_plugin_path,
							languages = { "vue" },
						},
					},
				},
				filetypes = { "typescript", "javascript", "vue" },
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>fr",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "Format File",
			},
		},
		opts = {
			notify_on_error = true,
			format_on_save = function(bufnr)
				return {
					timeout_ms = 5000,
					lsp_format = "fallback",
				}
			end,
			formatters_by_ft = {
				bash = { "shfmt" },
				zsh = { "shfmt" },
				sh = { "shfmt" },
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				javascriptreact = { "prettier" },
				vue = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				go = { "goimports", "gofumpt" },
				sql = { "pg_format" },
				zig = { "zigfmt" },
				yaml = { "yamlfmt" },
			},
		},
	},
	{ "zapling/mason-conform.nvim" },
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "default",
				["<C-Enter>"] = { "select_and_accept" },
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = { documentation = { auto_show = false } },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
		opts_extend = { "sources.default" },
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	-- code outline
	{
		"stevearc/aerial.nvim",
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
