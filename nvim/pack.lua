local gh = function(x)
	return "https://github.com/" .. x
end

-- Hooks
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
		if name == "blink.cmp" and (kind == "install" or kind == "update") then
			vim.system({ "cargo", "build", "--release" }, { cwd = ev.data.path }):wait()
		end
	end,
})

-- Install and load all plugins
vim.pack.add({
	-- Coding
	gh("nvim-treesitter/nvim-treesitter"),
	gh("L3MON4D3/LuaSnip"),
	gh("neovim/nvim-lspconfig"),
	gh("williamboman/mason.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	gh("stevearc/conform.nvim"),
	gh("zapling/mason-conform.nvim"),
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.0") },
	gh("rafamadriz/friendly-snippets"),
	gh("windwp/nvim-autopairs"),
	gh("stevearc/aerial.nvim"),

	-- Files
	gh("nvim-telescope/telescope.nvim"),
	gh("nvim-lua/plenary.nvim"),
	gh("utilyre/barbecue.nvim"),
	gh("SmiteshP/nvim-navic"),
	gh("nvim-tree/nvim-web-devicons"),
	gh("mikavilpas/yazi.nvim"),
	gh("folke/snacks.nvim"),

	-- UI
	gh("scottmckendry/cyberdream.nvim"),
	gh("nvim-lualine/lualine.nvim"),
	gh("folke/which-key.nvim"),
	gh("uga-rosa/ccc.nvim"),

	-- Terminal
	gh("akinsho/toggleterm.nvim"),

	-- Text
	gh("gbprod/cutlass.nvim"),
	gh("MagicDuck/grug-far.nvim"),

	-- Copilot
	gh("github/copilot.vim"),
})

-- Plugin configs

-- Treesitter: highlighting is handled via FileType autocmd by nvim-treesitter

-- LSP
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
		"oxfmt",
		"yaml-language-server",
		"typescript-language-server",
		"vue-language-server",
		"goimports",
		"gofumpt",
	},
})

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

-- Conform
require("conform").setup({
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
		javascript = { "oxfmt" },
		typescript = { "oxfmt" },
		typescriptreact = { "oxfmt" },
		javascriptreact = { "oxfmt" },
		vue = { "oxfmt" },
		json = { "oxfmt" },
		html = { "oxfmt" },
		css = { "oxfmt" },
		go = { "goimports", "gofumpt" },
		sql = { "pg_format" },
		zig = { "zigfmt" },
		yaml = { "yamlfmt" },
		handlebars = { "djlint" },
	},
})
vim.keymap.set("", "<leader>fr", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format File" })

-- Blink completion
require("blink.cmp").setup({
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
})

-- Autopairs
require("nvim-autopairs").setup()

-- Aerial
require("aerial").setup()

-- Telescope
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"node_modules/",
			".git/",
			"vendor/",
			"testdata/",
			"**.sql.go",
			"**.gen.go",
			"**schema.json",
			"package%-lock.json",
			"coverage/",
		},
		ripgrep_arguments = { "-S" },
	},
	pickers = {
		find_files = {
			hidden = true,
		},
	},
})

-- Barbecue
require("barbecue").setup()

-- Yazi
require("yazi").setup({
	open_for_directories = false,
	keymaps = {
		show_help = "<f1>",
	},
})
vim.g.loaded_netrwPlugin = 1
vim.keymap.set({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
vim.keymap.set("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open the file manager in nvim's working directory" })

-- Cyberdream
require("cyberdream").setup({
	overrides = function(colors)
		return {
			Comment = { fg = colors.grey, bg = "NONE", italic = true },
		}
	end,
})
vim.cmd.colorscheme("cyberdream")

-- Lualine
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

-- Which-key
require("which-key").setup({
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
})

-- CCC (color picker)
vim.opt.termguicolors = true
require("ccc").setup({
	highlighter = {
		auto_enable = true,
		lsp = true,
	},
})

-- Toggleterm
require("toggleterm").setup({
	size = 20,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
})

-- Cutlass
require("cutlass").setup({
	cut_key = "x",
})

-- Grug-far
require("grug-far").setup({ headerMaxWidth = 80 })
vim.keymap.set({ "n", "v" }, "<leader>sr", function()
	require("grug-far").open({ transient = true })
end, { desc = "Search and Replace" })
