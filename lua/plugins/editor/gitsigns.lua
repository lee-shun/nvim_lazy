return {
    "lewis6991/gitsigns.nvim",
    keys = { "<leader>g" },
    config = function()
        require("gitsigns").setup()
        local wk = require("which-key")
        wk.add({
            { "<leader>gj", function() require("gitsigns").next_hunk() end,         desc = "⬇️ Next hunk" },
            { "<leader>gk", function() require("gitsigns").prev_hunk() end,         desc = "⬆️ Prev hunk" },
            { "<leader>gs", function() require("gitsigns").stage_hunk() end,        desc = "➕ Stage hunk" },
            { "<leader>gr", function() require("gitsigns").reset_hunk() end,        desc = "↩️ Reset hunk" },
            { "<leader>gp", function() require("gitsigns").preview_hunk() end,      desc = "👁️ Preview hunk" },
            { "<leader>gb", function() require("gitsigns").blame_line() end,        desc = "📝 Blame line" },
            { "<leader>gd", function() require("gitsigns").diffthis() end,          desc = "📊 Diff" },
            { "<leader>gD", function() require("gitsigns").toggle_deleted() end,    desc = "🚫 Toggle deleted" },
            { "<leader>gl", function() require("gitsigns").setloclist() end,        desc = "📋 Git loclist" },
            { "<leader>gS", function() require("gitsigns").stage_buffer() end,      desc = "📦 Stage buffer" },
            { "<leader>gR", function() require("gitsigns").reset_buffer() end,      desc = "♻️ Reset buffer" },
            { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end,   desc = "↩️ Undo stage hunk" },
        })
    end,
}
