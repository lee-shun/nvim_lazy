return {
    "windwp/nvim-spectre",
    -- stylua: ignore
    keys = {
        { "<leader>cr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
}
