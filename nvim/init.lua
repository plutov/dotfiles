require("config.lazy")

vim.wo.number = true
vim.api.nvim_set_option("clipboard", "unnamed")
vim.opt.listchars = { space = "·", tab = "  " }
vim.opt.list = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
vim.keymap.set("n", "<leader>bf", builtin.buffers, { desc = "Open Buffers" })
local fk_opts = {
	cwd = "~/.config/nvim",
	results_title = "Config",
}
vim.keymap.set("n", "<leader>fc", function()
	builtin.find_files(fk_opts)
end, { desc = "Search Config Files" })

vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
	desc = "Toggle Spectre",
})
vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
	desc = "Search current word",
})
vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
	desc = "Search current word",
})
vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
	desc = "Search on current file",
})
