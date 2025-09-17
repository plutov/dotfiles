require("config.lazy")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.wo.number = true
vim.o.swapfile = false

-- No welcome screen
vim.opt.shortmess:append("I")

-- everything is unnamed
vim.api.nvim_set_option("clipboard", "unnamed")

-- split navigation
vim.api.nvim_set_keymap("n", "<C-h>", ":wincmd h<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":wincmd j<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":wincmd k<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", ":wincmd l<CR>", { silent = true })

-- Setup tabs and spaces
vim.opt.listchars = { space = "·", tab = "  " }
vim.opt.list = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

local indent_group = vim.api.nvim_create_augroup("IndentSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = { "go", "make", "lua" },
	callback = function()
		vim.opt.expandtab = false
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = { "js", "ts" },
	callback = function()
		vim.opt.expandtab = true
	end,
})

-- Finder
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
vim.keymap.set("n", "<leader>bf", builtin.buffers, { desc = "Open Buffers" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols" })
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
local fk_opts = {
	cwd = "~/.config/nvim",
	results_title = "Config",
}
vim.keymap.set("n", "<leader>fc", function()
	builtin.find_files(fk_opts)
end, { desc = "Search Config Files" })

-- Expand long diagnostics
vim.keymap.set(
	"n",
	"<leader>d",
	":lua vim.diagnostic.open_float()<CR>",
	{ noremap = true, silent = true, desc = "Expand Diagnostics" }
)
