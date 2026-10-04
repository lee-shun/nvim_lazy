return {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    keys = { "<leader>f" },
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-tree/nvim-web-devicons" },
        { "nvim-telescope/telescope-media-files.nvim",
        config=function()
            require("telescope").load_extension("media_files")
        end
             },
        {
            "nvim-telescope/telescope-ui-select.nvim",
            config = function()
                require("telescope").load_extension("ui-select")
            end,
        },
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
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.5,
                        results_width = 0.8,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                file_sorter = require("telescope.sorters").get_fuzzy_file,
                file_ignore_patterns = {},
                path_display = { "truncate" },
                border = {},
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                color_devicons = true,
                set_env = { ["COLORTERM"] = "truecolor" },
            },
            extensions = {
                live_grep_args = {
                    auto_quoting = true,
                    mappings = {
                        i = {
                            ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                        },
                    },
                },
                undo = {
                    side_by_side = true,
                    mappings = {
                        i = {
                            ["<C-a>"] = require("telescope-undo.actions").yank_additions,
                            ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
                            ["<cr>"] = require("telescope-undo.actions").restore,
                        },
                    },
                },
            },
            pickers = {
                buffers = {
                    mappings = {
                        i = {
                            -- bdelete 语义：关掉选中 buffer（terminal 类型自动 force），
                            -- 当前 buffer 被关时自动跳到上/下一个有效 buffer
                            ["<leader>d"] = actions.delete_buffer,
                        },
                    },
                },
            },
        })

        -- keymaps
        local wk = require("which-key")
        wk.add({
            { "<leader>fQ", "<cmd>Telescope quickfix<cr>",                  desc = "📋 Quickfix list" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "📑 Buffers" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>",               desc = "⚠️ Diagnostics" },
            { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "🔍 Files" },
            { "<leader>fj", "<cmd>Telescope jumplist<cr>",                  desc = "📍 Jumplist" },
            { "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "📍 Line in buffer" },
            { "<leader>fm", "<cmd>Telescope oldfiles<cr>",                  desc = "📁 Old files" },
            { "<leader>fp", "<cmd>Telescope resume<cr>",                    desc = "🔁 Resume picker" },
            { "<leader>fq", "<cmd>Telescope loclist<cr>",                   desc = "📍 Location list" },
            { "<leader>fr", "<cmd>Telescope registers<cr>",                 desc = "📋 Registers" },
            { "<leader>fw", "<cmd>Telescope live_grep<cr>",                 desc = "🔍 Live grep" },
        })
    end,
}
