local vue_plugin_path = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

return {
	name = "ts_ls",
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_plugin_path,
				languages = { "vue" },
			},
		},
	},
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
}