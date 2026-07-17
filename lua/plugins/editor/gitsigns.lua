return {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    keys = {
        { "]h", function() require("gitsigns").next_hunk() end, desc = "⬇️ Next hunk" },
        { "[h", function() require("gitsigns").prev_hunk() end, desc = "⬆️ Prev hunk" },
        { "H",  function() require("gitsigns").preview_hunk() end, desc = "👁️ Preview hunk" },
        { "L",  function() require("gitsigns").setloclist() end, desc = "📋 Git loclist" },
    },
    config = true,
}
