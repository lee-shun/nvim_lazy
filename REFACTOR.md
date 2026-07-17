# nvim 配置模块化重构方案

> **状态：已实施完成。** 仓库已按本文档完成重构，并通过 `nvim --headless -c 'q'` 启动验证。

## 1. 目标与原则

将当前仓库从“插件平铺 + 散落脚本”结构，重构成类似 LazyVim 的分层、可维护结构：

- **配置入口单一化**：`init.lua` 只负责 bootstrap 与加载 `lua/config/init.lua`。
- **职责按目录拆分**：核心选项、按键、自动命令、文件类型配置、插件配置分门别类。
- **公共函数统一沉淀**：把多个插件 / `ftplugin` / `plugin` 都会用到的辅助函数集中到 `lua/util/`。
- **插件按领域分组**：`coding`、`editor`、`ui`、`ai`、`writing`、`run` 等子目录。
- **最小侵入**：保持现有行为不变，仅做物理移动与依赖路径调整。

---

## 1.5 插件 spec 书写风格：`return {}` vs `local M = {}`

lazy.nvim 的插件 spec 本质是一个 Lua table，两种写法都合法：

### 写法 A：直接 `return {}`（推荐作为默认）

```lua
-- lua/plugins/coding/conform.lua
return {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo", "Format" },
    keys = { ... },
    opts = { ... },
}
```

优点：
- 与 LazyVim 社区风格一致，是最常见的 lazy.nvim 写法。
- 没有额外变量，阅读时直接看到“这是一个插件 spec”。
- 代码更少，适合 90% 的简单插件。

### 写法 B：`local M = {}` 再 `return M`

```lua
-- lua/plugins/coding/conform.lua
local M = {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo", "Format" },
    keys = { ... },
}

function M.config(_, opts)
    require("conform").setup(opts)
    vim.api.nvim_create_user_command("Format", function()
        require("conform").format({ async = true, lsp_fallback = true })
    end, {})
end

return M
```

适用场景：
- spec 较复杂，需要在 `opts`、`config`、`keys`、`dependencies` 之外定义本地辅助函数。
- 需要给 spec 加 `---@type LazyPluginSpec` 类型注解。
- 需要条件组装 spec（例如根据平台或启用开关动态修改字段）。

### 结论

**默认采用写法 A（直接 `return {}`），仅在插件配置复杂到需要拆分本地函数或类型注解时才使用 `local M = {}`。**

这样既能保持 lazy.nvim/LazyVim 的 idiomatic 风格，又不会在复杂插件里硬套单一形式。本文档后续示例均遵循此约定。

---

## 2. 现状诊断

### 2.1 目录现状

```
nvim/
├── init.lua                        # bootstrap lazy + require config.options + lazy.setup("plugins") + config.mappings
├── lua/config/
│   ├── options.lua                 # 全局选项
│   └── mappings.lua                # 全局按键（含 which-key 定义）
├── lua/plugins/                    # 70+ 个平铺的插件 spec
│   ├── alpha.lua
│   ├── cmp.lua
│   ├── lspconfig.lua
│   ├── overseer.lua
│   ├── ...
│   └── telescope.lua
├── lua/util/                       # 少量公共函数
│   ├── markdown_ordered_list.lua   # 既是工具又注册按键
│   ├── markdown_unordered_list.lua
│   ├── relative_path.lua
│   └── visual_selection.lua
├── plugin/                         # Vim 风格的运行时脚本
│   ├── general.lua                 # 自动命令
│   ├── searchcode.vim              # 视觉搜索函数
│   └── timestamp.vim               # 保存时更新时间戳
├── after/ftplugin/                 # 文件类型配置 + 内联自定义函数
│   ├── c,cpp.lua
│   ├── markdown.lua
│   ├── python.lua
│   ├── tex.lua
│   └── typst.lua
├── after/plugin/LargeFile.vim      # 大文件优化
└── template/、snip/、assist/ 等     # 资源目录
```

### 2.2 主要问题

| 问题 | 说明 |
|------|------|
| 启动入口重 | `init.lua` 直接加载 options、lazy、mappings；后续新增初始化逻辑会膨胀 |
| 插件目录平铺 | 70+ 文件在一个目录，难以快速定位 |
| 公共逻辑散落 | `find_root`、`is_ros2_workspace`、`is_cmake_project`、`visual selection`、`wrap pattern` 等被重复内联 |
| `plugin/` 与 `after/plugin/` 保留旧式结构 | 与 lazy.nvim 风格不统一，且与 `lua/config/` 割裂 |
| `ftplugin` 中塞业务逻辑 | `markdown.lua` 里写时间戳、frontmatter、list toggle；`tex.lua` 里写文本包裹；既长又难复用 |
| 工具模块边界不清 | `util/markdown_ordered_list.lua` 既提供函数又注册按键 |
| `snip/package.json` 指向不存在文件 | 大量 snippets 路径在仓库中不存在，需要清理或补齐 |

### 2.3 可沉淀的公共能力

- **视觉选择与 buffer 编辑**：`util/visual_selection.lua` 现有 `exit_visual_and_get_range`、`visual_to_normal`，可扩展为通用 selection/buffer 工具。
- **路径处理**：`util/relative_path.lua` 仅一个函数，可合并到通用 path 工具。
- **项目根目录/类型检测**：`overseer.lua` 中 `find_root` / `is_ros2_workspace` / `is_cmake_project` 被多处使用。
- **Markdown 工具**：有序/无序列表 toggle、frontmatter 更新、时间戳插入。
- **文本包裹**：`tex.lua` 中的 `wrap_with_pattern` 可用于多文件类型。
- **通知/消息**：多处 `vim.notify(...)` 模式一致，可封装 `util.notify.warn/info`。
- **模板扫描**：`telescope/_extensions/find_template.lua` 中 `scan_templates` 可与模板插件解耦。

---

## 3. 目标架构

```
nvim/
├── init.lua                         # 仅 bootstrap + require("config")
├── lazy-lock.json
├── README.md
├── REFACTOR.md                      # 本文档
│
├── lua/config/                      # 核心配置（LazyVim 风格）
│   ├── init.lua                     # 统一加载 options/autocmds/keymaps/lazy
│   ├── lazy.lua                     # lazy.nvim bootstrap + require("plugins")
│   ├── options.lua                  # vim.opt / vim.g（现有，精简）
│   ├── autocmds.lua                 # 自动命令（从 plugin/general.lua 迁移）
│   └── keymaps.lua                  # 全局按键（从 config/mappings.lua 迁移）
│
├── lua/lang/                        # 文件类型相关工具与配置
│   ├── init.lua                     # 注册所有文件类型事件
│   ├── markdown.lua                 # markdown 专用函数 + 按键（来自 after/ftplugin/markdown.lua）
│   ├── tex.lua                      # tex 专用函数 + 按键（来自 after/ftplugin/tex.lua）
│   ├── cpp.lua                      # c/c++ 按键（来自 after/ftplugin/c,cpp.lua）
│   ├── python.lua                   # python 选项（来自 after/ftplugin/python.lua）
│   └── typst.lua                    # typst 命令与按键（来自 after/ftplugin/typst.lua）
│
├── lua/util/                        # 通用工具库
│   ├── init.lua                     # 导出聚合
│   ├── buffer.lua                   # buffer 行/文本操作、游标
│   ├── visual.lua                   # 视觉模式辅助（原 visual_selection.lua）
│   ├── path.lua                     # 路径/相对路径/根目录探测
│   ├── project.lua                  # ROS2 / CMake / 通用项目检测
│   ├── markdown.lua                 # Markdown 通用工具（list、frontmatter、timestamp）
│   ├── wrap.lua                     # 通用文本包裹（来自 tex.lua）
│   ├── notify.lua                   # 轻量消息封装
│   └── template.lua                 # 模板扫描（来自 telescope/_extensions/find_template.lua）
│
├── lua/plugins/                     # 插件配置按领域分组
│   ├── init.lua                     # 组合并暴露所有 spec
│   ├── coding/                      # 代码相关
│   │   ├── cmp.lua
│   │   ├── luasnip.lua
│   │   ├── lspconfig.lua
│   │   ├── mason.lua
│   │   ├── lspsaga.lua
│   │   ├── conform.lua
│   │   ├── null_ls.lua
│   │   ├── dap.lua
│   │   ├── treesitter.lua
│   │   ├── vimtex.lua
│   │   └── ros.lua
│   ├── editor/                      # 编辑器增强
│   │   ├── telescope.lua
│   │   ├── telescope_live_grep_args.lua
│   │   ├── telescope_undo.lua
│   │   ├── nvimtree.lua
│   │   ├── which_key.lua
│   │   ├── gitsigns.lua
│   │   ├── todo_comments.lua
│   │   ├── trouble.lua
│   │   ├── spectre.lua
│   │   ├── yanky.lua
│   │   ├── mini_*.lua
│   │   └── ...
│   ├── ui/                          # 界面/主题
│   │   ├── sonokai.lua
│   │   ├── alpha.lua
│   │   ├── lualine.lua
│   │   ├── noice.lua
│   │   ├── notify.lua
│   │   ├── dropbar.lua
│   │   ├── indent_blankline.lua
│   │   └── ...
│   ├── ai/                          # AI 插件
│   │   ├── avante.lua
│   │   ├── codecompanion.lua
│   │   ├── opencode.lua
│   │   ├── minuet.lua
│   │   └── llama_vim.lua
│   ├── writing/                     # 写作/笔记
│   │   ├── obsidian.lua
│   │   ├── telekasten.lua
│   │   ├── markdown_preview.lua
│   │   ├── markdown_render.lua
│   │   ├── markdown_plus.lua
│   │   ├── clipboard_img.lua
│   │   └── typst_preview.lua
│   └── run/                         # 构建运行
│       └── overseer.lua
│
├── lua/telescope/_extensions/
│   └── find_template.lua            # 保留，但扫描逻辑移到 util.template
│
├── after/ftplugin/                  # 仅保留极简入口，转发到 lua/lang
│   ├── c,cpp.lua                    # require("lang.cpp").setup()
│   ├── markdown.lua                 # require("lang.markdown").setup()
│   ├── python.lua
│   ├── tex.lua
│   └── typst.lua
│
├── plugin/                          # 清空，逻辑迁移到 lua/config/autocmds.lua
├── after/plugin/                    # 清空或保留第三方大文件脚本
├── template/
├── snip/
├── assist/
├── spell/
└── tmp/
```

---

## 4. 关键模块设计

### 4.1 `lua/config/init.lua`

```lua
local M = {}

function M.setup()
    require("config.options")
    require("config.lazy")          -- bootstrap + lazy.setup
    require("config.autocmds")
    require("config.keymaps")
    require("lang").setup()         -- 文件类型配置
end

return M
```

### 4.2 `lua/config/lazy.lua`

把 `init.lua` 中 lazy bootstrap 与 `require("lazy").setup("plugins")` 移入，使 `init.lua` 只剩：

```lua
require("config").setup()
```

### 4.3 `lua/config/autocmds.lua`

合并来源：

- `plugin/general.lua`：恢复位置、Yank 高亮、formatoptions、cursorline、文件类型识别、相对行号切换、smartcase 动态切换、保存时 `TimeStamp()`。
- `plugin/timestamp.vim`：用 Lua 重写 `TimeStamp()` 注册为全局函数（因 autocmd 调用）。
- `plugin/searchcode.vim`：视觉搜索 `<Plug>` 映射或 Lua 函数，整合到 `util/visual.lua`。
- `after/plugin/LargeFile.vim`：保留在原地或迁移为 Lua autocmd（保持 vim 脚本亦可，但统一放到 `after/plugin/` 或 `lua/config/autocmds.lua` 的 `vim.cmd` 调用）。

### 4.4 `lua/config/keymaps.lua`

合并来源：

- `lua/config/mappings.lua` 全部内容。
- `after/ftplugin/*` 中通用型按键（只留 buffer-local 的在 `lua/lang/*`）。
- 统一使用 `which-key` 分组，例如 `<leader>f` Find、`<leader>l` LSP、`<leader>r` Run/Build、`<leader>d` Debug、`<leader>m` Markdown。

### 4.5 `lua/util/` 详细设计

#### `util/buffer.lua`

```lua
local M = {}

-- 获取当前光标位置
function M.cursor_pos()
    local pos = vim.api.nvim_win_get_cursor(0)
    return pos[1] - 1, pos[2]
end

-- 在光标处插入文本并移动光标
function M.insert_text_at_cursor(text)
    local row, col = M.cursor_pos()
    vim.api.nvim_buf_set_text(0, row, col, row, col, { text })
    vim.api.nvim_win_set_cursor(0, { row + 1, col + #text })
end

-- 替换缓冲区行范围
function M.set_lines(start_row, end_row, lines)
    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, lines)
end

-- 读取缓冲区行范围
function M.get_lines(start_row, end_row)
    return vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
end

return M
```

#### `util/visual.lua`

保留并扩展原 `util/visual_selection.lua`：

```lua
local M = {}

-- 退出 visual 模式并获取选中范围（行号、列号、文本）
function M.with_selection(callback)
    -- 现有逻辑优化：支持不重置 '< '>
end

-- 获取 visual 模式下的起止位置
function M.get_visual_pos()
    local s = vim.fn.getpos("'<")
    local e = vim.fn.getpos("'>")
    return s, e
end

-- visual 模式转换后执行
function M.from_normal_line(callback)
    -- 原 visual_to_normal
end

return M
```

#### `util/path.lua`

```lua
local M = {}

function M.relative(from, to)
    local dir = vim.fs.dirname(from)
    return vim.fs.relpath(dir, to) or "."
end

function M.config()
    return vim.fn.stdpath("config")
end

function M.join(...)
    return table.concat({ ... }, "/")
end

return M
```

#### `util/project.lua`

迁移自 `overseer.lua`：

```lua
local M = {}

function M.find_root(markers, start_path)
    -- 通用根目录探测
end

function M.is_ros2_workspace(start_path)
    -- 返回 ok, root
end

function M.is_cmake_project(start_path)
    -- 返回 ok, root
end

return M
```

#### `util/markdown.lua`

迁移并合并：

```lua
local M = {}

function M.toggle_ordered_list(lines)
    -- 纯函数：输入 lines，返回新 lines 与是否已转换
end

function M.toggle_unordered_list(lines, marker)
    -- 纯函数
end

function M.update_frontmatter_date(lines, field)
    -- 返回新 lines、是否修改
end

function M.insert_timestamp()
    -- 来自 after/ftplugin/markdown.lua 的 insert_formatted_time
end

return M
```

#### `util/wrap.lua`

迁移自 `after/ftplugin/tex.lua`：

```lua
local M = {}

-- pattern: 如 "\\boldsymbol"
-- 支持 normal / visual-block / visual-line / visual-char
function M.wrap_selection(pattern)
    -- 原 wrap_with_pattern 逻辑
end

return M
```

#### `util/template.lua`

迁移自 `telescope/_extensions/find_template.lua` 的 `scan_templates`：

```lua
local M = {}

local cache = nil

function M.scan()
    -- 返回模板列表 { name, display, full_path }
end

function M.clear_cache()
    cache = nil
end

return M
```

#### `util/notify.lua`

```lua
local M = {}

function M.info(msg) vim.notify(msg, vim.log.levels.INFO) end
function M.warn(msg) vim.notify(msg, vim.log.levels.WARN) end
function M.err(msg) vim.notify(msg, vim.log.levels.ERROR) end

return M
```

### 4.6 `lua/lang/` 详细设计

#### `lua/lang/init.lua`

注册 `FileType` autocmd，按文件类型分发到各模块：

```lua
local M = {}

local langs = {
    markdown = "lang.markdown",
    tex = "lang.tex",
    plaintex = "lang.tex",
    c = "lang.cpp",
    cpp = "lang.cpp",
    python = "lang.python",
    typst = "lang.typst",
}

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            local mod = langs[args.match]
            if mod then
                require(mod).setup(args.buf)
            end
        end,
    })
end

return M
```

#### `lua/lang/markdown.lua`

负责：

- tabstop/shiftwidth/spell 设置
- which-key buffer-local 映射：`<leader>mr` preview、`<C-t>` insert time
- 注册 user command：`UpdateDate`、`UpdateCreated`
- 加载 `util/markdown.lua` 的 list toggle，并映射 `<leader>mn`、`<leader>mu`、`<leader>mU`

#### `lua/lang/tex.lua`

负责：

- textwidth/spell 设置
- `<leader>rt` recompile / `<leader>rv` view
- `<leader>bd` bold：调用 `util.wrap.wrap_selection("\\boldsymbol")`

#### `lua/lang/cpp.lua`

负责 c/c++ 的 `<leader>rs` RunSingleFile。

#### `lua/lang/python.lua`

仅设置 textwidth。

#### `lua/lang/typst.lua`

注册 `OpenPdf` 命令。

---

## 5. 插件目录迁移表

> 所有迁移后的插件 spec 默认采用 `return {}` 写法（见 1.5 节）。对于 `overseer.lua`、`opencode.lua` 这类包含大量本地辅助函数的复杂插件，可视情况改为 `local M = {}` 以提升可读性。

| 原文件 | 新路径 | 备注 |
|--------|--------|------|
| `lua/plugins/cmp.lua` | `lua/plugins/coding/cmp.lua` | 抽取 `kind_icons` 到 `util/icons.lua`（可选） |
| `lua/plugins/lspconfig.lua` | `lua/plugins/coding/lspconfig.lua` | 抽取 on_attach 到 `util/lsp.lua` |
| `lua/plugins/mason.lua` | `lua/plugins/coding/mason.lua` | 不变 |
| `lua/plugins/lspsaga.lua` | `lua/plugins/coding/lspsaga.lua` | 不变 |
| `lua/plugins/conform.lua` | `lua/plugins/coding/conform.lua` | 不变 |
| `lua/plugins/null_ls.lua` | `lua/plugins/coding/null_ls.lua` | 不变 |
| `lua/plugins/dap.lua` | `lua/plugins/coding/dap.lua` | 不变 |
| `lua/plugins/treesitter.lua` | `lua/plugins/coding/treesitter.lua` | 不变 |
| `lua/plugins/vimtex.lua` | `lua/plugins/coding/vimtex.lua` | 也可放 writing |
| `lua/plugins/ros.lua` | `lua/plugins/coding/ros.lua` | 不变 |
| `lua/plugins/telescope.lua` | `lua/plugins/editor/telescope.lua` | 不变 |
| `lua/plugins/telescope_*.lua` | `lua/plugins/editor/` | 不变 |
| `lua/plugins/nvimtree.lua` | `lua/plugins/editor/nvimtree.lua` | 不变 |
| `lua/plugins/which_key.lua` | `lua/plugins/editor/which_key.lua` | 不变 |
| `lua/plugins/gitsigns.lua` | `lua/plugins/editor/gitsigns.lua` | 不变 |
| `lua/plugins/sonokai.lua` | `lua/plugins/ui/sonokai.lua` | 主题 |
| `lua/plugins/alpha.lua` | `lua/plugins/ui/alpha.lua` | 启动页 |
| `lua/plugins/lualine.lua` | `lua/plugins/ui/lualine.lua` | 状态栏 |
| `lua/plugins/noice.lua` | `lua/plugins/ui/noice.lua` | 消息UI |
| `lua/plugins/notify.lua` | `lua/plugins/ui/notify.lua` | 通知 |
| `lua/plugins/avante_ai.lua` | `lua/plugins/ai/avante.lua` | 重命名 |
| `lua/plugins/codecompanion.lua` | `lua/plugins/ai/codecompanion.lua` | 不变 |
| `lua/plugins/opencode.lua` | `lua/plugins/ai/opencode.lua` | 不变 |
| `lua/plugins/minuet_ai.lua` | `lua/plugins/ai/minuet.lua` | 重命名 |
| `lua/plugins/llama_vim.lua` | `lua/plugins/ai/llama_vim.lua` | 不变 |
| `lua/plugins/obsidian_nvim.lua` | `lua/plugins/writing/obsidian.lua` | 重命名 |
| `lua/plugins/telekasten.lua` | `lua/plugins/writing/telekasten.lua` | 不变 |
| `lua/plugins/markdown_*.lua` | `lua/plugins/writing/` | 不变 |
| `lua/plugins/clipboard_img.lua` | `lua/plugins/writing/clipboard_img.lua` | 不变 |
| `lua/plugins/typst_preview.lua` | `lua/plugins/writing/typst_preview.lua` | 不变 |
| `lua/plugins/overseer.lua` | `lua/plugins/run/overseer.lua` | 使用 `util/project.lua` |
| `lua/plugins/literature_manager.lua` | `lua/plugins/writing/literature_manager.lua` | 不变 |

### 5.1 `lua/plugins/init.lua`

lazy.nvim 可以通过目录 `lua/plugins/` 自动收集，但若使用子目录，需要显式 import：

```lua
return {
    { import = "plugins.coding" },
    { import = "plugins.editor" },
    { import = "plugins.ui" },
    { import = "plugins.ai" },
    { import = "plugins.writing" },
    { import = "plugins.run" },
}
```

### 5.2 跨子目录共享

- `util/path.lua`：被 `obsidian`、`telescope find_template`、`template` 使用。
- `util/project.lua`：被 `overseer` 使用，未来可被 `lspconfig`、`dap` 复用。
- `util/lsp.lua`（新增）：统一 `on_attach`、capabilities 生成，被 `lspconfig` 使用。
- `util/icons.lua`（新增）：`cmp.lua`、`lspconfig.lua`、`dap.lua` 中的图标集合。

---

## 6. 文件类型配置迁移

### 6.1 `after/ftplugin/` 瘦身

每个文件只保留：

```lua
require("lang.markdown").setup(vim.api.nvim_get_current_buf())
```

业务逻辑全部进入 `lua/lang/markdown.lua`。

### 6.2 `lua/lang/markdown.lua` 示例

```lua
local M = {}

function M.setup(buf)
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.spell = true

    local wk = require("which-key")
    wk.add({
        { "<leader>mr", "<cmd>MarkdownPreview<cr>", buffer = buf, desc = "Preview" },
        { "<C-t>", function() require("util.markdown").insert_timestamp() end, buffer = buf, mode = "i", desc = "Insert time" },
        { "<leader>mn", function() require("lang.markdown").toggle_ordered() end, buffer = buf, desc = "Toggle ordered list" },
        { "<leader>mu", function() require("lang.markdown").toggle_unordered() end, buffer = buf, desc = "Toggle unordered list" },
        { "<leader>mU", function() require("lang.markdown").toggle_unordered_indent() end, buffer = buf, desc = "Toggle unordered list (indent)" },
    })

    vim.api.nvim_buf_create_user_command(buf, "UpdateDate", function()
        M.update_date("date")
    end, {})
    vim.api.nvim_buf_create_user_command(buf, "UpdateCreated", function()
        M.update_date("created")
    end, {})
end

function M.toggle_ordered()
    require("util.visual").with_selection(function(lines, row0, row1)
        local md = require("util.markdown")
        local new_lines, _ = md.toggle_ordered_list(lines)
        vim.api.nvim_buf_set_lines(0, row0, row1 + 1, false, new_lines)
    end)
end

-- ... 其他函数

return M
```

---

## 7. 公共函数 API 总览

| 模块 | 函数 | 用途 |
|------|------|------|
| `util.buffer` | `cursor_pos`、`insert_text_at_cursor`、`get_lines`、`set_lines` | buffer 文本操作 |
| `util.visual` | `with_selection`、`get_visual_pos`、`from_normal_line` | visual 模式辅助 |
| `util.path` | `relative`、`config`、`join` | 路径 |
| `util.project` | `find_root`、`is_ros2_workspace`、`is_cmake_project` | 项目检测 |
| `util.markdown` | `toggle_ordered_list`、`toggle_unordered_list`、`update_frontmatter_date`、`insert_timestamp` | Markdown 工具 |
| `util.wrap` | `wrap_selection(pattern)` | 文本包裹 |
| `util.template` | `scan`、`clear_cache` | 模板扫描 |
| `util.notify` | `info`、`warn`、`err` | 通知 |
| `util.lsp`（新增） | `on_attach`、`capabilities` | LSP 共享 |
| `util.icons`（新增） | `lsp_kinds`、`diagnostics` | 图标 |

---

## 8. 实施步骤

### Phase 1：基础设施（不破坏现有配置）

1. 创建 `lua/config/init.lua`、`lua/config/lazy.lua`。
2. 将 `init.lua` 改为 `require("config").setup()`。
3. 把 `plugin/general.lua` 逻辑迁移到 `lua/config/autocmds.lua`。
4. 把 `config/mappings.lua` 重命名为 `lua/config/keymaps.lua`（更新引用）。
5. 把 `plugin/timestamp.vim`、`plugin/searchcode.vim` 重写成 Lua 并合并进 `autocmds.lua` / `util/`。

### Phase 2：创建公共工具库

1. 新建 `lua/util/buffer.lua`、`path.lua`、`project.lua`、`markdown.lua`、`wrap.lua`、`template.lua`、`notify.lua`、`lsp.lua`、`icons.lua`。
2. 逐步把 `util/visual_selection.lua`、`util/relative_path.lua` 替换为 `util/visual.lua`、`util/path.lua`（保留旧文件做兼容，内部转发）。
3. 从 `overseer.lua` 提取 `find_root` / `is_ros2_workspace` / `is_cmake_project` 到 `util/project.lua`。
4. 从 `after/ftplugin/markdown.lua` 提取 Markdown 工具到 `util/markdown.lua`。
5. 从 `after/ftplugin/tex.lua` 提取 wrap 到 `util/wrap.lua`。
6. 从 `telescope/_extensions/find_template.lua` 提取扫描到 `util/template.lua`。

### Phase 3：文件类型配置模块化

1. 新建 `lua/lang/init.lua`、`lua/lang/markdown.lua`、`tex.lua`、`cpp.lua`、`python.lua`、`typst.lua`。
2. 把 `after/ftplugin/*` 改为 require 对应 `lang` 模块。
3. 验证 Markdown list toggle、Tex bold、C++ RunSingleFile、Typst OpenPdf 行为不变。

### Phase 4：插件目录重组

1. 创建 `lua/plugins/{coding,editor,ui,ai,writing,run}/`。
2. 按迁移表移动/重命名文件。
3. 创建 `lua/plugins/init.lua` 并显式 `import` 各子目录。
4. 把所有对 `util/` 的旧引用（`util.relative_path`、`util.visual_selection`、`util.markdown_ordered_list` 等）更新为新路径。

### Phase 5：清理与验证

1. 删除空的 `plugin/`、`after/plugin/`（若 `LargeFile.vim` 保留，建议放到 `after/plugin/` 并加说明）。
2. 启动 Neovim，检查：
   - 无 Lua 报错
   - `which-key` 分组正常
   - LSP 能 attach
   - Telescope 能打开
   - Markdown list toggle 工作
   - `<leader>rb` / `<leader>rr` overseer 工作
3. 运行 `:checkhealth` 查看依赖状态。

---

## 9. 兼容性策略

- **旧 `util/` 转发**：在迁移期间，`util/visual_selection.lua`、`util/relative_path.lua` 内部只 `return require("util.visual")`、`return require("util.path")`，防止历史引用断裂。
- **旧插件名保留**：`avante_ai.lua` → `ai/avante.lua` 后无旧引用，不需要转发。
- **`TimeStamp()`**：`plugin/timestamp.vim` 提供全局函数，改为 `lua/config/autocmds.lua` 中 `_G.TimeStamp = ...`，保证 `BufWritePre` autocmd 可用。
- **snippets 清理**：`snip/package.json` 中大量不存在的 snippet 文件，建议单独一次 PR 清理或补齐。

---

## 10. 预期收益

- 新增插件/功能时，能立即判断应放在哪个目录。
- 多个插件共享的 root 探测、visual 选择、markdown 工具不再复制粘贴。
- `init.lua` 与配置加载解耦，便于以后切换包管理器或做条件加载。
- `ftplugin` 与业务逻辑解耦，单个语言配置可独立测试。

---

## 11. 风险与回滚

| 风险 | 缓解 |
|------|------|
| 移动文件导致 lazy.nvim 找不到 spec | 分步迁移，每次改完立即启动验证 |
| `require` 路径漏改 | 使用 `rg "require\("` 全仓库检查 |
| 文件类型事件重复触发 | `lua/lang/init.lua` 只用一次 `FileType` autocmd |
| 视觉模式函数时序变化 | 保留 `defer_fn` 与 mark 重置逻辑，单元测试 list toggle |
| 大文件脚本 `LargeFile.vim` 失效 | 保留在 `after/plugin/`，不做重写 |

---

## 12. 下一步

确认本方案后，按 Phase 1 → Phase 5 逐步执行。建议每一步提交一次 git，便于 review 与回滚。
