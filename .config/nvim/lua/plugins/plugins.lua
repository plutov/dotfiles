return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        keys = {
            { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find Files", mode = "n" },
            { "<leader>n", "<cmd>Neotree<cr>",              desc = "Neotree",    mode = "n" },
        },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme catppuccin-mocha]])
        end,
    },
    -- Make sure to install https://www.nerdfonts.com first
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            filesystem = {
                filtered_items = {
                    visible = true,
                },
            },
        },
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("lualine").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local mason = require("mason")

            mason.setup()

            lspconfig.gopls.setup({})
            lspconfig.yamlls.setup({})
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'fatih/vim-go'
    }
}
