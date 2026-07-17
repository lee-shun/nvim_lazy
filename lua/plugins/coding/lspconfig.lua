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
        local lsp_util = require("util.lsp")
        local on_attach = lsp_util.on_attach
        local capabilities = lsp_util.capabilities()

        -- clangd needs utf-16 offset encoding
        local clangd_cap = vim.deepcopy(capabilities)
        clangd_cap.offsetEncoding = { "utf-16" }

        local clangd_on_attach = function(client, bufnr)
            require("which-key").add({
                { "<leader>l",  group = "📡 LSP",                       buffer = bufnr },
                { "<leader>lj", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "🔀 Switch header", buffer = bufnr },
            })
            return on_attach(client, bufnr)
        end

        vim.lsp.enable("clangd")
        vim.lsp.config("clangd", {
            cmd = { "clangd", "--clang-tidy=0" },
            on_attach = clangd_on_attach,
            capabilities = clangd_cap,
        })

        -- cmake
        vim.lsp.enable("neocmake")
        vim.lsp.config("neocmake", {
            on_attach = on_attach,
            capabilities = capabilities,
        })

        -- basedpyright
        vim.lsp.enable("basedpyright")
        vim.lsp.config("basedpyright", {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = "basic",
                        diagnosticSeverityOverrides = {
                            reportUnknownArgumentType = "none",
                        },
                    },
                },
            },
        })

        -- texlab
        vim.lsp.enable("texlab")
        vim.lsp.config("texlab", {
            on_attach = on_attach,
            capabilities = capabilities,
        })

        -- typst (tinymist)
        local typst_on_attach = function(client, bufnr)
            local notify = require("util.notify")
            vim.keymap.set("n", "<leader>xp", function()
                client:exec_cmd({
                    title = "pin",
                    command = "tinymist.pinMain",
                    arguments = { vim.api.nvim_buf_get_name(0) },
                }, { bufnr = bufnr })
                notify.info("Pin current buffer as main!")
            end, { desc = "📌 Pin Main", noremap = true, buffer = bufnr })

            vim.keymap.set("n", "<leader>xu", function()
                client:exec_cmd({
                    title = "unpin",
                    command = "tinymist.pinMain",
                    arguments = { vim.v.null },
                }, { bufnr = bufnr })
                notify.info("Unpin current buffer as main!")
            end, { desc = "📌 Unpin Main", noremap = true, buffer = bufnr })

            require("which-key").add({
                { "<leader>x", group = "TeX / Typst", icon = { icon = "📐", color = "Cyan" }, buffer = bufnr },
                { "<leader>xp", desc = "📌 Pin Main", buffer = bufnr },
                { "<leader>xu", desc = "📌 Unpin Main", buffer = bufnr },
            })

            return on_attach(client, bufnr)
        end

        vim.lsp.enable("tinymist")
        vim.lsp.config("tinymist", {
            on_attach = typst_on_attach,
            capabilities = capabilities,
            settings = {
                formatterMode = "typstyle",
                exportPdf = "onType",
                semanticTokens = "disable",
            },
        })

        -- bash
        vim.lsp.enable("bashls")
        vim.lsp.config("bashls", {
            on_attach = on_attach,
            capabilities = capabilities,
        })

        -- lua
        local runtime_path = vim.split(package.path, ";")
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")

        vim.lsp.enable("lua_ls")
        vim.lsp.config("lua_ls", {
            on_attach = on_attach,
            capabilities = capabilities,
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
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        })

        -- Global diagnostic configuration (signs, floats, virtual text)
        lsp_util.setup_diagnostics()
    end,
}
