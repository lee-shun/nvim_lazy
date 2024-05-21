return {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    keys = { "<leader>f" },
    dependencies = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        { "nvim-tree/nvim-web-devicons" },
    },
    config = function()
        local present, telescope = pcall(require, "telescope")
        if not present then
            return
        end

        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                },
                prompt_prefix = "   ",
                selection_caret = " ",
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                    },
                },
                initial_mode = "insert",
                selection_strategy = "reset",
                sorting_strategy = "descending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                file_ignore_patterns = {},
                generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
                path_display = { "truncate" },
                winblend = 0,
                border = {},
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                color_devicons = true,
                use_less = true,
                set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
                file_previewer = require("telescope.previewers").vim_buffer_cat.new,
                grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
                qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
                -- Developer configurations: Not meant for general override
                buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
            },
        })


        -- keymaps
        local wk = require("which-key")
        local telescope_map = {
            f = {
                name = "Find",
                f = { "<cmd>Telescope find_files<cr>", "Find file" },
                b = { "<cmd>Telescope buffers<cr>", "Find buffers" },
                m = { "<cmd>Telescope oldfiles<cr>", "Find old files" },
                o = { "<cmd>Telescope oldfiles<cr>", "Find old files" },
                w = { "<cmd>Telescope live_grep<cr>", "Find word" },
                l = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find line in current buffer" },
                r = { "<cmd>Telescope registers<cr>", "Find registers" },
                d = { "<cmd>Telescope diagnostics<cr>", "Find diagnostics" },
                j = { "<cmd>Telescope jumplist<cr>", "Find jumplist" },
                y = { "<cmd>Telescope yank_history<cr>", "Find yank history" },
                q = { "<cmd>Telescope loclist<cr>", "Find location list" },
                Q = { "<cmd>Telescope quickfix<cr>", "Find quickfix list" },
                p = { "<cmd>Telescope resume<cr>", "Resume previous picker" },
            },
        }
        local telescope_map_opt = {
            mode = "n",
            prefix = "<leader>",
            buffer = nil,
            silent = true,
            noremap = true,
            nowait = false,
        }
        wk.register(telescope_map, telescope_map_opt)
    end,
}
