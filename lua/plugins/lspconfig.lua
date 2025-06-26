return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "mason.nvim",
        "lspsaga.nvim",
        "williamboman/mason-lspconfig.nvim",
        {
            "smjonas/inc-rename.nvim",
            cmd = "IncRename",
            config = function()
                require("inc_rename").setup()
            end,
        },
    },
    config = function()
        local wk = require("which-key")

        local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { scope = "local" })

            wk.add({
                { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>",     desc = "Declaration",             nowait = false, remap = false },
                { "gH", "<cmd>lua vim.lsp.buf.signature_help()<cr>",  desc = "Signature help",          nowait = false, remap = false },
                { "gd", "<cmd>Lspsaga goto_definition<cr>",           desc = "Lspsaga goto definition", nowait = false, remap = false },
                { "gh", "<cmd>Lspsaga hover_doc<cr>",                 desc = "Lspsaga Hover",           nowait = false, remap = false },
                { "gi", "<cmd>Telescope lsp_implementations<cr>",     desc = "Goto implementation",     nowait = false, remap = false },
                { "gr", "<cmd>lua vim.lsp.buf.references()<cr>",      desc = "Goto reference",          nowait = false, remap = false },
                { "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", desc = "Goto type definition",    nowait = false, remap = false },
            })

            -- diagnostic
            wk.add({
                { "<leader>l",  group = "LSP",                              nowait = false,            remap = false },
                { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",   desc = "Lsp code action",  nowait = false, remap = false },
                { "<leader>ld", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Diagnostic float", nowait = false, remap = false },
                {
                    "<leader>li",
                    function()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end,
                    desc = "IncRename",
                    expr = true,
                    nowait = false,
                    remap = false,
                    replace_keycodes = false
                },
                { "<leader>lr", "<cmd>Lspsaga rename<cr>", desc = "Lspsaga rename", nowait = false, remap = false },
            })

            wk.add({
                { "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Lsp prev diagnostic", nowait = false, remap = false },
                { "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Lsp next diagnostic", nowait = false, remap = false },
            })
        end

        --
        -- cmp + lsp
        --
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
        }

        local cmp_cap = require("cmp_nvim_lsp").default_capabilities(capabilities)

        -- clangd
        local clangd_cap = cmp_cap
        clangd_cap.offsetEncoding = { "utf-16" }
        local clangd_on_attach = function(client, bufnr)
            wk.add({
                { "<leader>l",  group = "LSP",                       nowait = false,                remap = false },
                { "<leader>lj", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Clangd switch header", nowait = false, remap = false },
            })

            return on_attach(client, bufnr)
        end
        require("lspconfig").clangd.setup({
            on_attach = clangd_on_attach,
            capabilities = clangd_cap,
        })

        -- cmake
        require("lspconfig").cmake.setup({
            on_attach = on_attach,
            capabilities = cmp_cap,
        })

        -- pyright
        local pyright_cap = cmp_cap
        require("lspconfig").pyright.setup({
            on_attach = on_attach,
            capabilities = pyright_cap,
        })

        -- -- pylyzer
        -- local pylyzer = cmp_cap
        -- require("lspconfig").pylyzer.setup({
        -- 	on_attach = on_attach,
        -- 	capabilities = pylyzer,
        -- })

        -- taxlab
        require("lspconfig").texlab.setup({
            on_attach = on_attach,
            capabilities = cmp_cap,
        })

        -- typst
        require("lspconfig").tinymist.setup({
            on_attach = on_attach,
            capabilities = cmp_cap,
            settings = {
                formatterMode = "typstyle",
                exportPdf = "onType",
                semanticTokens = "disable"
        }
        })

        -- bash
        require("lspconfig").bashls.setup({
            on_attach = on_attach,
            capabilities = cmp_cap,
        })

        -- lua
        local runtime_path = vim.split(package.path, ";")
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")

        require("lspconfig").lua_ls.setup({
            on_attach = on_attach,
            capabilities = cmp_cap,
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = runtime_path,
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false, -- THIS IS THE IMPORTANT LINE TO ADD
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        })

        -- set icons (if not use lspsaga)
        local symbols = { Error = " ", Warn = " ", Info = " ", Hint = " " }
        for type, icon in pairs(symbols) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
    end,
}
