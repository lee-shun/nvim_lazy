return {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    -- commit = "3e8fceb",
    keys = {
        { "n",  [[<cmd>execute('normal! ' . v:count1 . 'n')<cr><cmd>lua require('hlslens').start()<cr>]], desc = "🔎 Next search" },
        { "N",  [[<cmd>execute('normal! ' . v:count1 . 'N')<cr><cmd>lua require('hlslens').start()<cr>]], desc = "🔎 Prev search" },
        { "*",  [[*<cmd>lua require('hlslens').start()<cr>]], desc = "🔎 Search word" },
        { "#",  [[#<cmd>lua require('hlslens').start()<cr>]], desc = "🔎 Search word (backward)" },
        { "g*", [[g*<cmd>lua require('hlslens').start()<cr>]], desc = "🔎 Search whole word" },
        { "g#", [[g#<cmd>lua require('hlslens').start()<cr>]], desc = "🔎 Search whole word (backward)" },
    },
    config = true,
}
