return {
    "michaelb/sniprun",
    branch = "master",
    cmd = { "SnipRun" },
    build = "sh install.sh",
    config = function()
        require("sniprun").setup({
            display = {
                "NvimNotify",
            },
        })
    end,
}
