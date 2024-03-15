return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo", "Format" },
    keys = {
        {
            -- Customize or remove this keymap to your liking
            "<leader>cf",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
    -- Everything in opts will be passed to setup()
    opts = {
        -- Set up format-on-save
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
    config = function(_, opts)
        require("conform").setup(opts)
        vim.api.nvim_create_user_command("Format",
            function() require("conform").format({ async = true, lsp_fallback = true }) end, {})
    end
}
