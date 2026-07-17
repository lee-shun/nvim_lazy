-- Shared LSP helpers: on_attach keymaps and capabilities generation.

local M = {}

---Default LSP on_attach function used by most language servers.
---Sets up buffer-local keymaps via which-key.
---@param client table
---@param bufnr integer
function M.on_attach(client, bufnr)
    local wk = require("which-key")

    -- Enable omnifunc
    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { scope = "local" })

    -- Navigation
    wk.add({
        { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>",     desc = "Declaration",             buffer = bufnr },
        { "gH", "<cmd>lua vim.lsp.buf.signature_help()<cr>",  desc = "Signature help",          buffer = bufnr },
        { "gd", "<cmd>Lspsaga goto_definition<cr>",           desc = "Lspsaga goto definition", buffer = bufnr },
        { "gh", "<cmd>Lspsaga hover_doc<cr>",                 desc = "Lspsaga Hover",           buffer = bufnr },
        { "gi", "<cmd>Telescope lsp_implementations<cr>",     desc = "Goto implementation",     buffer = bufnr },
        { "gr", "<cmd>lua vim.lsp.buf.references()<cr>",      desc = "Goto reference",          buffer = bufnr },
        { "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", desc = "Goto type definition",    buffer = bufnr },
    })

    -- LSP group
    wk.add({
        { "<leader>l",  group = "LSP",                              buffer = bufnr },
        { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",   desc = "Lsp code action",  buffer = bufnr },
        { "<leader>ld", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Diagnostic float", buffer = bufnr },
        {
            "<leader>li",
            function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end,
            desc = "IncRename",
            expr = true,
            replace_keycodes = false,
            buffer = bufnr,
        },
        { "<leader>lr", "<cmd>Lspsaga rename<cr>", desc = "Lspsaga rename", buffer = bufnr },
    })

    -- Diagnostics navigation
    wk.add({
        { "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Lsp prev diagnostic", buffer = bufnr },
        { "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Lsp next diagnostic", buffer = bufnr },
    })
end

---Build enhanced LSP capabilities with snippet and folding support.
---@return table
function M.capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }
    return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

---Configure global diagnostic signs and floats.
function M.setup_diagnostics()
    local icons = require("util.icons").diagnostics
    vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = true,
        float = {
            focusable = true,
            style = "minimal",
            border = "rounded",
            source = true,
            header = "",
            prefix = "",
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = icons.Error,
                [vim.diagnostic.severity.WARN] = icons.Warn,
                [vim.diagnostic.severity.HINT] = icons.Hint,
                [vim.diagnostic.severity.INFO] = icons.Info,
            },
        },
    })
end

return M
