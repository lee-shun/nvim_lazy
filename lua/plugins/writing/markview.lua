-- 终端内 markdown 预览（不开浏览器）。
-- 现有 <leader>mr（iamcco/markdown-preview.nvim，浏览器）保持不变，
-- markview 用 <leader>mR 触发分栏预览，试错期间两者并存。
return {
    "OXY2DEV/markview.nvim",
    -- 作者要求 eager load：插件自己注册 filetype autocmd，
    -- 加 lazy 触发器（ft/event/keys）会让首次预览变慢。纯 Lua，启动开销可忽略。
    -- 本 spec 位于 writing/（在 ui/ 之后导入），colorscheme(sonokai) 先于它加载，
    -- 满足作者“在 colorscheme 之后加载”的要求。
    opts = {
        preview = {
            -- 关键：默认不开启原地渲染（markview 默认对 attach 的 markdown buffer
            -- 自动渲染）。保持现状：编辑时的原地渲染仍由 render-markdown.nvim 负责，
            -- markview 只用于按需的 :Markview / :Markview splitToggle 分栏预览。
            enable = false,
            icon_provider = "internal", -- 不硬依赖 nvim-web-devicons / mini.icons
        },
    },
    config = function(_, opts)
        require("markview").setup(opts)
        -- 分栏预览（独立窗口 + 滚动同步），终端内渲染
        vim.keymap.set("n", "<leader>mR", "<cmd>Markview splitToggle<cr>", {
            desc = "👁️ MD Split Preview (terminal)",
        })
        -- render-markdown.nvim 也对 ft=markdown 的 buffer 做原地渲染，
        -- markview 预览 buffer 的 ft 同样是 markdown，两者叠加会双重装饰。
        -- 在 markview 预览 buffer 上禁用 render-markdown（延迟到本 autocmd 轮之后，
        -- 确保 render-markdown 已 attach）。
        local function exclude_from_render_markdown(buf)
            vim.schedule(function()
                local ok1, mv_state = pcall(require, "markview.state")
                if not ok1 or not mv_state.get_splitview_buffer then return end
                if mv_state.get_splitview_buffer() ~= buf then return end
                local ok2, rm_manager = pcall(require, "render-markdown.core.manager")
                if ok2 and type(rm_manager.set_buf) == "function" then
                    rm_manager.set_buf(buf, false)
                end
            end)
        end
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function(args)
                exclude_from_render_markdown(args.buf)
            end,
        })
    end,
}
