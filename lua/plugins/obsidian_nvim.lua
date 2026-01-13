return {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    version = "*",
    ft = "markdown",
    dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",
    },
    opts = {
        legacy_commands = false,
        workspaces = {
            {
                name = "knowledge_library",
                path = "~/knowledge_library"
            },
        },
        preferred_link_style = "markdown",
        new_notes_location = "current_dir",
        completion = { nvim_cmp = true },
        ui = {
            enable = false
        },
        note_id_func = function(title)
            if not title then return "untitled" end
            local s = title
                -- 替换各类空白为下划线
                :gsub("%s+", "_")
                :gsub("　", "_") -- 全角空格
                -- 移除文件系统非法字符
                :gsub("[\\/:*?\"<>|%%#&{}~+]", "")
                -- 处理中文标点（提升可读性）
                :gsub("（", "_")
                :gsub("）", "")
                :gsub("、", "_")
                :gsub("，", "_")
                :gsub("。", "")
                -- 清理多余下划线
                :gsub("_+", "_")
                :gsub("^_+", "")
                :gsub("_+$", "")
            return s == "" and "untitled" or s
        end,
        ---@param opts { path: string, label: string, id: string|integer|?, anchor: obsidian.note.HeaderAnchor|?, block: obsidian.note.Block|? }
        ---@return string
        markdown_link_func = function(opts)
            local api = require("obsidian").api
            local current_note = api.current_note(0, {})

            local ws = api.find_workspace(opts.path)

            local target_path_str = ws.path.filename .. "/" .. opts.path

            local relative = require("util.relative_path").relative_path(current_note.path.filename, target_path_str)

            return string.format("[%s](%s)", opts.label, relative)
        end,
        templates = {
            folder = ".obsidian_template",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M:%S",
        },
    },
}
