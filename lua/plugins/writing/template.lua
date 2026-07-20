return {
    -- NOTE: tibabit/vim-templates is unmaintained. Kept because the local
    -- template/ files use its {{FILEE}}, {{NAME}}, {{EMAIL}}, {{TODAY}}, {{CURSOR}}
    -- syntax and the custom telescope find_template extension depends on it.
    -- If migrating to nvimdev/template.nvim, update templates to its grammar first.
    "tibabit/vim-templates",
    pin = true,
    cmd = { "TemplateInit", "TemplateExpand" },
    keys = {
        { "<leader>ft", "<cmd>Telescope find_template<cr>", desc = "📋 File templates" },
    },
    config = function()
        vim.g.tmpl_auto_initialize = 0
        vim.g.tmpl_search_paths = { vim.fn.stdpath("config") .. "/template" }
        vim.g.tmpl_author_name = "shun li"
        vim.g.tmpl_author_email = "shun.li.at.casia@outlook.com"

        require("telescope").load_extension("find_template")
    end,
}
