-- 文件浏览器：nvim-tree → neo-tree（2025 起 LazyVim 默认；nvim-tree 已放缓更新）
-- 源：filesystem / buffers / git_status 三个源，用 < 和 > 切换（source_selector 标签默认关）
return {
    "neo-tree.nvim",
    keys = {
        { "<leader>t", "<cmd>Neotree toggle<cr>", desc = "📁 File Explorer" },
    },
    cmd = { "Neotree" }, -- v2.x 统一命令：:Neotree toggle/focus/show/close/float
    opts = {
        -- 行为对齐旧 nvim-tree 习惯
        enable_diagnostics = true,
        enable_git_status = true,
        enable_modified_markers = true, -- 未保存文件 [+] 标记
        open_files_in_last_window = true,
        window = {
            position = "left",
            width = 30,
            -- 键位映射：尽量沿用 nvim-tree 的肌肉记忆
            mappings = {
                ["<cr>"] = "open",
                ["l"] = "open",
                ["e"] = "open_split",          -- 水平分屏（nvim-tree: e）
                ["v"] = "open_vsplit",        -- 垂直分屏（nvim-tree: v）
                ["t"] = "open_tabnew",        -- 新 tab（nvim-tree: t）
                ["<C-e>"] = "open_drop",      -- 原地替换（nvim-tree: <C-e>）
                ["w"] = "open_with_window_picker",
                ["h"] = "close_node",         -- 关目录/返回上级（nvim-tree: h）
                ["a"] = "add",                -- 新建（nvim-tree: a）
                ["A"] = "add_directory",
                ["d"] = "delete",             -- 删除（nvim-tree: dF）
                ["y"] = "copy_to_clipboard",  -- 复制（nvim-tree: yy）
                ["x"] = "cut_to_clipboard",   -- 剪切（nvim-tree: dd）
                ["p"] = "paste_from_clipboard",
                ["r"] = "rename",             -- 重命名（nvim-tree: rn/rN）
                ["L"] = "expand_all_nodes",   -- 全部展开（nvim-tree: L）
                ["z"] = "close_all_nodes",    -- 全部折叠（nvim-tree: H）
                ["q"] = "close_window",
                ["R"] = "refresh",            -- 刷新（nvim-tree: <C-r>）
                ["?"] = "show_help",
            },
        },
        filesystem = {
            follow_current_file = true,      -- nvim-tree: update_focused_file
            bind_to_cwd = true,              -- nvim-tree: sync_root_with_cwd
            window = {
                mappings = {
                    ["<bs>"] = "navigate_up",        -- 上级目录（nvim-tree: <BS>）
                    ["/"] = "fuzzy_finder",          -- 过滤（nvim-tree: fs）
                    ["f"] = "filter_on_submit",
                    ["<C-x>"] = "clear_filter",
                    ["."] = "set_root",              -- 设为根（nvim-tree: CD 对应 <CR> 变体）
                    ["H"] = "toggle_hidden",         -- 显示/隐藏点文件+忽略文件（nvim-tree: <C-h>/. /<C-i> 合并）
                    ["[g"] = "prev_git_modified",
                    ["]g"] = "next_git_modified",
                },
            },
            filtered_items = {
                hide_dotfiles = false,       -- 旧配置 hide_dotfiles=false
                hide_gitignored = true,
                show_hidden_count = true,
            },
        },
        buffers = {
            follow_current_file = true,
        },
    },
}
