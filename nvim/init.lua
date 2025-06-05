require("config.lazy")

vim.wo.number = true

-- No welcome screen
vim.opt.shortmess:append("I")

-- everything is unnamed
vim.api.nvim_set_option("clipboard", "unnamed")

-- Setup tabs and spaces
vim.opt.listchars = { space = "·", tab = "  " }
vim.opt.list = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Finder
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
vim.keymap.set("n", "<leader>bf", builtin.buffers, { desc = "Open Buffers" })
local fk_opts = {
	cwd = "~/.config/nvim",
	results_title = "Config",
}
vim.keymap.set("n", "<leader>fc", function()
	builtin.find_files(fk_opts)
end, { desc = "Search Config Files" })

-- Exit the terminal
vim.api.nvim_set_keymap("t", "<ESC>", "<C-\\><C-n>", { noremap = true })

-- Expand long diagnostics
vim.api.nvim_set_keymap(
	"n",
	"<Leader>d",
	":lua vim.diagnostic.open_float()<CR>",
	{ noremap = true, silent = true, desc = "Expand Diagnostics" }
)
