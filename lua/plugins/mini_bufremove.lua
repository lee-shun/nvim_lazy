return {
    "echasnovski/mini.bufremove",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
        { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
        { "<leader>bD", function() require("mini.bufremove").delete(0, true) end,  desc = "Delete Buffer (Force)" },
    },
    config = function(_, opts)
        require("mini.bufremove").setup(opts)
        require("which-key").add({
            { "<leader>b", group = "Buffer", nowait = false, remap = false },
        })
    end,
}
