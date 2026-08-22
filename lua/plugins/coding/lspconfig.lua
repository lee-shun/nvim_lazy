return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "mason.nvim",
        "lspsaga.nvim",
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

        -- 切换 .cpp / .h（clangd 原生 textDocument/switchSourceHeader）
        -- 注意：Neovim 0.12 移除了 nvim_create_user_command 的 buffer 选项，
        -- 所以这里定义全局命令，调用时动态取当前 buffer。
        vim.api.nvim_create_user_command("ClangdSwitchSourceHeader", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local c = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
            if not c then
                vim.notify("clangd 未附加到当前缓冲区", vim.log.levels.WARN)
                return
            end
            -- 该请求只需要 TextDocumentIdentifier（uri），不需要位置信息
            c:request("textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(bufnr) }, function(err, result)
                if err then
                    vim.notify("clangd switchSourceHeader 请求失败: " .. vim.inspect(err), vim.log.levels.ERROR)
                elseif not result or result == "" then
                    vim.notify("clangd: 找不到对应的源/头文件", vim.log.levels.WARN)
                else
                    vim.cmd("edit " .. vim.uri_to_fname(result))
                end
            end)
        end, { desc = "Switch between source and header file" })

        local clangd_on_attach = function(client, bufnr)
            require("which-key").add({
                { "<leader>lj", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "🔀 Switch header", buffer = bufnr },
            })
            return on_attach(client, bufnr)
        end

        vim.lsp.config("clangd", {
            cmd = { "clangd", "--clang-tidy=0" },
            on_attach = clangd_on_attach,
            capabilities = clangd_cap,
        })
        vim.lsp.enable("clangd")

        -- cmake
        vim.lsp.config("neocmake", {
            on_attach = on_attach,
            capabilities = capabilities,
        })
        vim.lsp.enable("neocmake")

        -- basedpyright
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
        vim.lsp.enable("basedpyright")

        -- texlab
        vim.lsp.config("texlab", {
            on_attach = on_attach,
            capabilities = capabilities,
        })
        vim.lsp.enable("texlab")

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
                { "<leader>xp", desc = "📌 Pin main", buffer = bufnr },
                { "<leader>xu", desc = "📌 Unpin main", buffer = bufnr },
            })

            return on_attach(client, bufnr)
        end

        vim.lsp.config("tinymist", {
            on_attach = typst_on_attach,
            capabilities = capabilities,
            settings = {
                formatterMode = "typstyle",
                exportPdf = "onType",
                semanticTokens = "disable",
            },
        })
        vim.lsp.enable("tinymist")

        -- bash
        vim.lsp.config("bashls", {
            on_attach = on_attach,
            capabilities = capabilities,
        })
        vim.lsp.enable("bashls")

        -- lua
        -- 绝对路径：相对路径（./?.lua、lua/?.lua）会按工作区根解析，
        -- 在项目目录里编辑时找不到本配置的 lua 模块
        local config_path = vim.fn.stdpath("config")
        local runtime_path = {
            config_path .. "/?.lua",
            config_path .. "/?/init.lua",
        }

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
        vim.lsp.enable("lua_ls")

        -- Global diagnostic configuration (signs, floats, virtual text)
        lsp_util.setup_diagnostics()
    end,
}
