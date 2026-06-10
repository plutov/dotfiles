vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

dofile(vim.fn.stdpath("config") .. "/pack.lua")
vim.wo.number = true
vim.o.swapfile = false

-- No welcome screen
vim.opt.shortmess:append("I")

-- everything is unnamed
vim.opt.clipboard = "unnamed"

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
vim.keymap.set("n", "<leader>ff", function()
	require("fff").find_files()
end, { desc = "files" })
vim.keymap.set("n", "<leader>sg", function()
	require("fff").live_grep()
end, { desc = "grep" })
vim.keymap.set("n", "<leader>fc", function()
	require("fff").find_files_in_dir(vim.fn.expand("~/.config/nvim"))
end, { desc = "Search config files" })
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aerial toggle" })
vim.keymap.set("n", "<leader>bx", "<cmd>:%bd<CR>", { desc = "Close all buffers" })

-- Expand long diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { silent = true, desc = "Expand diagnostics" })

-- Built-in pack manager
vim.keymap.set("n", "<leader>pu", function()
	vim.pack.update()
end, { desc = "Pack update (review)" })

-- Copilot keymaps
vim.keymap.set("i", "<C-.>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true
