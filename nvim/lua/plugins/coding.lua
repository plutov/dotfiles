return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = { ensure_installed = { "helm" } },
	},
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
	},
	{ "towolf/vim-helm", ft = "helm" },
	{ "qvalentin/helm-ls.nvim", ft = "helm" },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
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

			local servers = {
				yamlls = {},
				helm_ls = {},
				gopls = {},
				zls = {},
				ts_ls = {},
				eslint = {},
				rust_analyzer = {},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			require("mason").setup()
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			local lspconfig = require("lspconfig")
			lspconfig.yamlls.setup({
				servers = {
					yamlls = {
						on_attach = function(client, buffer)
							if vim.bo[buffer].filetype == "helm" then
								vim.schedule(function()
									vim.cmd("LspStop ++force yamlls")
								end)
							end
						end,
					},
				},
			})
			lspconfig.gopls.setup({})
			lspconfig.zls.setup({})
			lspconfig.ts_ls.setup({})
			lspconfig.eslint.setup({})
			lspconfig.rust_analyzer.setup({})

			require("helm-ls").setup()
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
					timeout_ms = 1000,
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
				json = { "prettier" },
				html = { "prettier" },
				go = { "goimports", "gofumpt" },
				sql = { "pg_format" },
				zig = { "zigfmt" },
				yaml = {},
			},
		},
	},
	{ "zapling/mason-conform.nvim" },
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
				["<C-y>"] = { "select_and_accept" },
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
			fuzzy = { implementation = "prefer_rust_with_warning" },
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
