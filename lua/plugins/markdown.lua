return {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    event = "VeryLazy",
    opts = {
        mappings = {
            inline_surround_toggle = "<leader>m", -- (string|boolean) toggle inline style
            inline_surround_toggle_line = "<leader>mm", -- (string|boolean) line-wise toggle inline style
            inline_surround_delete = "<leader>md", -- (string|boolean) delete emphasis surrounding cursor
            inline_surround_change = "<leader>mc", -- (string|boolean) change emphasis surrounding cursor
            link_add = "<leader>ml",             -- (string|boolean) add link
            link_follow = "<leader>mx",          -- (string|boolean) follow link
            go_curr_heading = "]c",      -- (string|boolean) set cursor to current section heading
            go_parent_heading = "]p",    -- (string|boolean) set cursor to parent section heading
            go_next_heading = "]]",      -- (string|boolean) set cursor to next section heading
            go_prev_heading = "[[",      -- (string|boolean) set cursor to previous section heading
        },
        on_attach = function(buffer)
            local map = vim.keymap.set
            local opts = {buffer = buffer}

            map({'n', 'i'}, '<M-j>', '<Cmd>MDListItemBelow<CR>', opts)
            map({'n', 'i'}, '<M-k>', '<Cmd>MDListItemAbove<CR>', opts)
        end,
    },
}
