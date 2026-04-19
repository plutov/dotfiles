vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

dofile(vim.fn.stdpath("config") .. "/pack.lua")
vim.wo.number = true
vim.o.swapfile = false

-- No welcome screen
vim.opt.shortmess:append("I")

-- everything is unnamed
vim.opt.clipboard = "unnamed"

-- split navigation
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", { silent = true, desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<CR>", { silent = true, desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<CR>", { silent = true, desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<CR>", { silent = true, desc = "Window right" })

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
	callback = function(ev)
		vim.bo[ev.buf].expandtab = false
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = { "js", "ts" },
	callback = function(ev)
		vim.bo[ev.buf].expandtab = true
	end,
})

-- Finder
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "git files" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "diagnostics" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "grep" })
vim.keymap.set("n", "<leader>bf", builtin.buffers, { desc = "buffers" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "symbols" })
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aerial toggle" })
vim.keymap.set("n", "<leader>bx", "<cmd>:%bd<CR>", { desc = "Close all buffers" })
local fk_opts = {
	cwd = "~/.config/nvim",
	results_title = "Config",
}
vim.keymap.set("n", "<leader>fc", function()
	builtin.find_files(fk_opts)
end, { desc = "Search config files" })

-- Expand long diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { silent = true, desc = "Expand diagnostics" })

-- Built-in pack manager
vim.keymap.set("n", "<leader>pu", function()
	vim.pack.update()
end, { desc = "Pack update (review)" })
vim.keymap.set("n", "<leader>pU", function()
	vim.pack.update(nil, { force = true })
end, { desc = "Pack update (force)" })
vim.keymap.set("n", "<leader>pl", function()
	vim.pack.update(nil, { offline = true, target = "lockfile" })
end, { desc = "Pack sync from lockfile" })
vim.keymap.set("n", "<leader>pL", function()
	vim.cmd.edit(vim.fs.joinpath(vim.fn.stdpath("log"), "nvim-pack.log"))
end, { desc = "Open pack log" })

-- Copilot keymaps
vim.keymap.set("i", "<C-.>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true
