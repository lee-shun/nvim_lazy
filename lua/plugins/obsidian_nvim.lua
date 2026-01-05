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
        templates = {
            folder = ".obsidian_template",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M:%S",
        },
    },
}
