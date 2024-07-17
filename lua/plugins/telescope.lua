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
        wk.add(
            {
                { "<leader>f",  group = "Find",                                 nowait = false,                       remap = false },
                { "<leader>fQ", "<cmd>Telescope quickfix<cr>",                  desc = "Find quickfix list",          nowait = false, remap = false },
                { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Find buffers",                nowait = false, remap = false },
                { "<leader>fd", "<cmd>Telescope diagnostics<cr>",               desc = "Find diagnostics",            nowait = false, remap = false },
                { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Find file",                   nowait = false, remap = false },
                { "<leader>fj", "<cmd>Telescope jumplist<cr>",                  desc = "Find jumplist",               nowait = false, remap = false },
                { "<leader>fl", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find line in current buffer", nowait = false, remap = false },
                { "<leader>fm", "<cmd>Telescope oldfiles<cr>",                  desc = "Find old files",              nowait = false, remap = false },
                { "<leader>fo", "<cmd>Telescope oldfiles<cr>",                  desc = "Find old files",              nowait = false, remap = false },
                { "<leader>fp", "<cmd>Telescope resume<cr>",                    desc = "Resume previous picker",      nowait = false, remap = false },
                { "<leader>fq", "<cmd>Telescope loclist<cr>",                   desc = "Find location list",          nowait = false, remap = false },
                { "<leader>fr", "<cmd>Telescope registers<cr>",                 desc = "Find registers",              nowait = false, remap = false },
                { "<leader>fw", "<cmd>Telescope live_grep<cr>",                 desc = "Find word",                   nowait = false, remap = false },
                { "<leader>fy", "<cmd>Telescope yank_history<cr>",              desc = "Find yank history",           nowait = false, remap = false },
            }
        )
    end,
}
