vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

dofile(vim.fn.stdpath("config") .. "/pack.lua")
vim.wo.number = true
vim.o.swapfile = false

-- No welcome screen
vim.opt.shortmess:append("I")

-- everything is unnamed
vim.opt.clipboard = "unnamedplus"

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
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "files" })
vim.keymap.set("n", "<leader>sg", telescope.live_grep, { desc = "grep" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>bf", telescope.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fc", function()
	telescope.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Search config files" })
vim.keymap.set("n", "<leader>fp", function()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("No file path for current buffer", vim.log.levels.WARN)
		return
	end

	local relative_path = vim.fn.fnamemodify(path, ":.")
	vim.fn.setreg("+", relative_path)
	vim.notify("Copied relative path: " .. relative_path)
end, { desc = "Copy relative file path" })
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aerial toggle" })
vim.keymap.set("n", "<leader>bx", "<cmd>:%bd<CR>", { desc = "Close all buffers" })

vim.keymap.set("n", "<leader>th", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>tl", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tn", function()
	local cwd = vim.fn.getcwd(-1, 0)
	vim.cmd.tabnew()
	vim.cmd.tcd({ args = { cwd }, magic = { file = false } })
end, { desc = "New tab" })
vim.keymap.set("n", "<leader>tr", function()
	local tab = vim.api.nvim_get_current_tabpage()
	vim.ui.input({ prompt = "Tab name: ", default = vim.t[tab].tabname or "" }, function(name)
		if name == nil or not vim.api.nvim_tabpage_is_valid(tab) then
			return
		end
		name = vim.trim(name)
		vim.t[tab].tabname = name ~= "" and name or nil
		require("lualine").refresh({ place = { "tabline" } })
	end)
end, { desc = "Rename tab" })
vim.keymap.set("n", "<leader>td", ":<C-u>tcd ", { desc = "Change tab directory" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Close tab" })

-- Expand long diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { silent = true, desc = "Expand diagnostics" })

-- Built-in pack manager
vim.keymap.set("n", "<leader>pu", function()
	vim.pack.update()
end, { desc = "Pack update (review)" })
