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

    -- All LSP operations under gr prefix
    wk.add({
        -- Built-in defaults (registered for which-key display)
        { "gra", desc = "⚡ Code action",      buffer = bufnr },
        { "grr", desc = "📍 References",       buffer = bufnr },
        { "grn", desc = "✏️ Rename",           buffer = bufnr },
        { "gri", desc = "📍 Implementation",   buffer = bufnr },
        { "grt", desc = "📍 Type definition",  buffer = bufnr },
        { "grx", desc = "🔬 CodeLens run",     buffer = bufnr },
        -- Custom additions
        { "grd", "<cmd>Lspsaga goto_definition<cr>",    desc = "📍 Goto definition", buffer = bufnr },
        { "grD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "📍 Declaration",  buffer = bufnr },
        { "grh", "<cmd>Lspsaga hover_doc<cr>",          desc = "💡 Hover",            buffer = bufnr },
        { "grH", "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "💡 Signature help", buffer = bufnr },
    })

    -- Lower-frequency actions under <leader>l
    wk.add({
        { "<leader>lf", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "⚠️ Diagnostic float", buffer = bufnr },
        { "<leader>li",
            function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end,
            desc = "✏️ IncRename",
            expr = true,
            replace_keycodes = false,
            buffer = bufnr,
        },
    })

    -- Diagnostics navigation under <leader>l
    wk.add({
        { "<leader>l[", function() vim.diagnostic.jump({ count = -1, float = true }) end, desc = "⚠️ Prev diagnostic", buffer = bufnr },
        { "<leader>l]", function() vim.diagnostic.jump({ count = 1, float = true }) end, desc = "⚠️ Next diagnostic", buffer = bufnr },
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
