---Build / run plugin entry point.
---All functionality is delegated to `util.build`; this file only provides
---Lazy.nvim wiring and keymap bindings.

local project = require("util.project")
local build = require("util.build")

return {
    {
        -- 本地虚拟插件（lazy.nvim `virtual`）：不安装、不加 rtp，只承载 keys + config。
        -- 之前用自指 dir 指向 lua/plugins，会把该目录（非插件）加进 rtp。
        "buildrun",
        virtual = true,
        -- toggleterm 是构建/运行流程的真实依赖：之前只有 F12 触发其加载，
        -- 先按构建键会在 require("toggleterm.terminal") 处失败。
        -- （plenary 依赖已删：util.build 未使用，avante/obsidian 已声明）
        dependencies = { "akinsho/toggleterm.nvim" },
        keys = {
            -- Build
            { "<leader>rb", function() build.build(project) end, desc = "Build (Release)" },
            { "<leader>rB", function() build.build_debug(project) end, desc = "Build (Debug)" },
            { "<leader>rl", function() build.build_last(project) end, desc = "Build Last Args" },
            { "<leader>rc", function() build.clean(project) end, desc = "Clean" },
            -- Run
            { "<leader>rr", function() build.run(project) end, desc = "Run" },
            { "<leader>rR", build.build_and_run, desc = "Build & Run" },
            { "<leader>ra", function() build.run_with_args(project) end, desc = "Run with Args" },
            -- Terminal
            { "<leader>rt", build.toggle_terminal, desc = "Toggle Terminal" },
            { "<leader>rk", build.kill_terminal, desc = "Kill Terminal" },
            -- Debug (requires nvim-dap)
            { "<leader>rd", function() build.debug_cmake(project) end, desc = "Debug CMake Target" },
            { "<leader>rD", build.debug_single_file, desc = "Debug Single File" },
        },
        config = function()
            local wk = require("which-key")
            wk.add({
                { "<leader>rb", desc = "🔨 Build (Release)", icon = { icon = "󰙵", color = "green" } },
                { "<leader>rB", desc = "🐛 Build (Debug)", icon = { icon = "󰙵", color = "yellow" } },
                { "<leader>rl", desc = "🔁 Build Last Args", icon = { icon = "󰜉", color = "orange" } },
                { "<leader>rc", desc = "🧹 Clean", icon = { icon = "󰩹", color = "grey" } },
                { "<leader>rr", desc = "▶️ Run", icon = { icon = "󰜎", color = "cyan" } },
                { "<leader>rR", desc = "🔨▶️ Build & Run", icon = { icon = "󰓦", color = "orange" } },
                { "<leader>ra", desc = "▶️📎 Run with Args", icon = { icon = "󰜎", color = "purple" } },
                { "<leader>rt", desc = "📺 Toggle Terminal", icon = { icon = "󰌵", color = "blue" } },
                { "<leader>rk", desc = "🔌 Kill Terminal", icon = { icon = "󰜺", color = "red" } },
                { "<leader>rd", desc = "🐛 Debug CMake", icon = { icon = "󰃤", color = "red" } },
                { "<leader>rD", desc = "🐛 Debug Single File", icon = { icon = "󰃤", color = "red" } },
            })

            build.setup_autocmds(project)
        end,
    },
}
