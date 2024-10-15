return {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
    -- Make sure to install https://www.nerdfonts.com first
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    },
    {
        "b0o/SchemaStore.nvim",
        enable = false
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            servers = {
                yamlls = {
                    settings = {
                        yaml = {
                            keyOrdering = false,
                            format = {
                                enable = true,
                            },
                            validate = false,
                            schemaStore = {
                                -- disable schemas
                                enable = false,
                                url = "",
                            },
                        },
                    },
                },
            }
        },
    },
    {
        "nvimdev/dashboard-nvim",
        opts = function()
            local opts = {
                theme = "doom",
                hide = {
                    statusline = false,
                },
                config = {
                    header = {
                        [[]],
                        [[]],
                        [[]],
                        [[]],
                        [[]],
                        [[NEOVIM]],
                        [[]],
                        [[]],
                        [[]],
                        [[]],
                        [[]],
                    },
                    -- stylua: ignore
                    center = {
                        { action = 'lua LazyVim.pick()()', desc = " Find File", icon = " ", key = "f" },
                        { action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
                        { action = 'lua LazyVim.pick("oldfiles")()', desc = " Recent Files", icon = " ", key = "r" },
                        { action = 'lua LazyVim.pick("live_grep")()', desc = " Find Text", icon = " ", key = "g" },
                        { action = 'lua LazyVim.pick.config_files()()', desc = " Config", icon = " ", key = "c" },
                        { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
                        { action = "LazyExtras", desc = " Lazy Extras", icon = " ", key = "x" },
                        { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
                        { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit", icon = " ", key = "q" },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
                    end,
                },
            }

            for _, button in ipairs(opts.config.center) do
                button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
                button.key_format = "  %s"
            end

            -- open dashboard after closing lazy
            if vim.o.filetype == "lazy" then
                vim.api.nvim_create_autocmd("WinClosed", {
                    pattern = tostring(vim.api.nvim_get_current_win()),
                    once = true,
                    callback = function()
                        vim.schedule(function()
                            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
                        end)
                    end,
                })
            end

            return opts
        end,
    }
}
