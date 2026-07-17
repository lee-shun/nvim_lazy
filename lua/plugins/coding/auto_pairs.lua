return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        local npairs = require("nvim-autopairs")
        npairs.setup({
            check_ts = true,
            disable_filetype = { "TelescopePrompt" },
        })
        npairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
    end,
}
