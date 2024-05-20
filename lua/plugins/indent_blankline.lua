return {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = { "rainbow-delimiters.nvim", "lee-shun/indent-rainbowline.nvim" },
    config = function(_, opts)
        local reg_color_func = function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end

        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }
        local hooks = require("ibl.hooks")
        hooks.register(hooks.type.HIGHLIGHT_SETUP, reg_color_func)
        vim.g.rainbow_delimiters = { highlight = highlight }
        hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

        opts = {
            indent = {
                char = { "│" },
                smart_indent_cap = true,
                tab_char = { "|" },
            },
            scope = {
                highlight = highlight,
            },
            exclude = {
                filetypes = {
                    "Nvimtree",
                    "coc-explorer",
                    "dashboard",
                    "alpha",
                    "noice",
                    "lspinfo",
                    "packer",
                    "checkhealth",
                    "help",
                    "man",
                    "gitcommit",
                    "TelescopePrompt",
                    "TelescopeResults",
                    "''",
                },
                buftypes = { "terminal", "prompt", "nofile", "quickfix" },
            },
        }

        local rainbowline_opts = {
            hl = highlight,
            colors = {
                0xE06C75,
                0xE5C07B,
                0x61AFEF,
                0xD19A66,
                0x98C379,
                0xC678DD,
                0x56B6C2,
            },
        }

        opts = require("indent-rainbowline").make_opts(opts, rainbowline_opts)
        require("ibl").setup(opts)
    end,
}
