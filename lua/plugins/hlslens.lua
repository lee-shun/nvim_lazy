return {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    commit = "3e8fceb",
    keys = {
        { "n",  [[<cmd>execute('normal! ' . v:count1 . 'n')<cr><cmd>lua require('hlslens').start()<cr>]] },
        { "N",  [[<cmd>execute('normal! ' . v:count1 . 'N')<cr><cmd>lua require('hlslens').start()<cr>]] },
        { "*",  [[*<cmd>lua require('hlslens').start()<cr>]] },
        { "#",  [[#<cmd>lua require('hlslens').start()<cr>]] },
        { "g*", [[g*<cmd>lua require('hlslens').start()<cr>]] },
        { "g#", [[g#<cmd>lua require('hlslens').start()<cr>]] },
    },
    config = true,
}
