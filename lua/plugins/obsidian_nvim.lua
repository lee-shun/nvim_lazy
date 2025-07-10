return {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    version = "*",
    ft = "markdown",
    dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "knowledge_library",
                path = "~/knowledge_library"
            },
        },
        preferred_link_style = "markdown",
        ui = {
            enable = false
        }
    },
}
