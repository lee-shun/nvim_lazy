# Keymap 组织设计与改进方案

## 一、问题分析

### 1. 时间戳函数泄漏到非 markdown buffer

**根因：** `lua/config/autocmds.lua:129-167` 中 `_G.TimeStamp()` 函数在 `BufWritePre` 事件上注册，**没有 filetype 过滤**，导致每个文件保存时都会扫描全文本查找 `Last changed:` 等模式并更新时间戳。

**影响：**
- 代码文件（C/C++、LaTeX 等）保存时也会触发，浪费时间
- 如果代码中恰好包含 `Modified:` 等字符串，会被意外修改

### 2. 按键冲突与覆盖

#### 冲突清单

| 按键 | 位置 A | 位置 B | 冲突类型 | 严重度 |
|------|--------|--------|----------|--------|
| `<C-h>` | `lua/config/keymaps.lua:28` — Toggle search highlight (n) | `lua/plugins/coding/luasnip.lua:41` — Jump backward in snippet (i,s) | **模式不同，无实际冲突** | 低 |
| `<Tab>` | `lua/config/keymaps.lua:13` — Next popup item (i) | `lua/plugins/editor/barbaric.lua` — Buffer navigation | **模式不同，无实际冲突** | 低 |
| `<S-Tab>` | `lua/config/keymaps.lua:17` — Prev popup item (i) | `lua/plugins/editor/barbaric.lua` — Buffer navigation | **模式不同，无实际冲突** | 低 |
| `n` / `N` | `lua/plugins/editor/hlslens.lua` — HLSearch lens | vim 默认搜索 | **覆盖默认行为**（预期） | 低 |
| `*` / `#` | `lua/plugins/editor/hlslens.lua` — HLSearch lens | vim 默认搜索 | **覆盖默认行为**（预期） | 低 |
| `<leader>f` | `lua/plugins/editor/telescope.lua` — Find group | 多个子映射 | **无冲突，是 group** | — |
| `<leader>l` | `lua/util/lsp.lua` — LSP group | `lua/plugins/coding/lspconfig.lua` — Clangd override | **后者覆盖前者** | **高** |
| `<leader>b` | `lua/plugins/coding/mini_bufremove.lua` — Buffer group | — | — | — |
| `<leader>d` | `lua/plugins/coding/dap.lua` — DAP group | — | — | — |
| `<leader>r` | `lua/plugins/run/overseer.lua` — Run/Build group | — | — | — |
| `<leader>m` | `lua/lang/markdown.lua` — Markdown ops | `lua/plugins/coding/lspconfig.lua` — Tinymist Pin/Unpin | **潜在冲突**（不同 filetype） | **中** |
| `<leader>mn` | `lua/lang/markdown.lua` — Toggle ordered list | — | — | — |
| `<leader>mu` | `lua/lang/markdown.lua` — Toggle unordered list | `lua/plugins/coding/lspconfig.lua:83` — Tinymist Unpin | **冲突！** typst buffer 中 `<leader>mu` 被覆盖 | **高** |
| `<leader>mp` | `lua/plugins/coding/lspconfig.lua:74` — Tinymist Pin | — | — | — |
| `[d` / `]d` | `lua/util/lsp.lua` — Diagnostic nav | `lua/plugins/editor/nvimtree.lua` — NvimTree internal | **不同 buffer 作用域，无冲突** | 低 |
| `J` / `K` | `lua/config/keymaps.lua:65-66` — Visual move | `lua/plugins/editor/nvimtree.lua` — NvimTree internal | **不同 buffer 作用域，无冲突** | 低 |
| `l` | `lua/plugins/editor/nvimtree.lua` — Open (tree buffer) | vim 默认移动 | **不同 buffer 作用域，无冲突** | 低 |
| `<leader>bd` | `lua/plugins/coding/mini_bufremove.lua` — Delete Buffer | `lua/lang/tex.lua` — Bold (boldsymbol) | **冲突！** tex buffer 中 `<leader>bd` 被后者覆盖 | **高** |
| `<leader>rs` | `lua/lang/cpp.lua` — Run single file | — | — | — |
| `<leader>rt` | `lua/lang/tex.lua` — Recompile LaTeX | — | — | — |
| `<leader>rv` | `lua/lang/tex.lua` — View PDF | — | — | — |
| `<leader>fn` | `lua/plugins/ui/notify.lua` — Find notify | — | — | — |
| `<leader>nu` | `lua/plugins/ui/notify.lua` — Dismiss notifications | — | — | — |
| `<leader>nl` / `<leader>nh` / `<leader>na` | `lua/plugins/ui/noice.lua` — Noice | — | — | — |
| `<leader>cr` | `lua/plugins/editor/spectre.lua` — Spectre | — | — | — |
| `<leader>cm` | `lua/plugins/coding/mason.lua` — Mason | — | — | — |
| `<leader>cf` | `lua/plugins/coding/conform.lua` — Format | — | — | — |
| `<leader>w` | `lua/plugins/editor/translator.lua` — Translate | — | — | — |
| `<leader>tt` | `lua/plugins/editor/toggleterm.lua` — Toggle terminal | — | — | — |
| `<leader>td` | `lua/plugins/editor/todo_comments.lua` — Todo | — | — | — |
| `<leader>vt` | `lua/plugins/editor/vista.lua` — Vista | — | — | — |
| `<leader>ut` | `lua/plugins/editor/undotree.lua` — UndoTree | — | — | — |
| `<leader>st` | `lua/plugins/editor/startuptime.lua` — Startuptime | — | — | — |
| `<leader>tk` | `lua/plugins/writing/telekasten.lua` — Telekasten | — | — | — |
| `<leader>lm` | `lua/plugins/writing/literature_manager.lua` — Literature | — | — | — |
| `<leader>ft` | `lua/plugins/writing/template.lua` — Templates | — | — | — |
| `<C-t>` | `lua/lang/markdown.lua` — Insert timestamp | — | — | — |

#### 描述不统一问题

- overseer 的 which-key 配置使用了 `icon` 和 `color` 字段，其他插件没有
- 描述文本风格不统一：有的用 "Find file"，有的用 "Find file"，有的用 "Telescope find_files"
- 缺少直观的 unicode 符号

---

## 二、改进方案

### 方案 1：时间戳泄漏修复

**策略：将全局时间戳更新限制到特定 filetype**

```lua
-- lua/config/autocmds.lua
api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.md", "*.org", "*.txt" },  -- 添加 pattern 过滤
    desc = "Auto-update timestamp before saving",
    callback = function()
        TimeStamp()
    end,
})
```

**替代方案：** 在 `TimeStamp()` 函数内部检查 `vim.bo.filetype`，只处理 markdown/org 等文本类文件。

**推荐：** 使用 pattern 过滤（更清晰，性能更好）。

---

### 方案 2：Keymap 统一组织

#### 2.1 冲突解决

| 冲突 | 解决方案 |
|------|----------|
| `<leader>mu` (markdown vs typst) | Markdown 保留 `<leader>mu`（更常用），typst 的 Tinymist Unpin 改为 `<leader>tU`（归入 tex/typst 专用 group） |
| `<leader>bd` (buffer vs tex) | Buffer 删除保留 `<leader>bd`（全局），tex 的 Bold 改为 `<leader>fb`（归入 formatting group） |
| `<leader>l` (LSP vs clangd) | 保持现状（clangd override 是正确的 per-buffer 行为） |

#### 2.2 统一 which-key 规范

**所有 which-key 注册统一遵循以下规范：**

1. **Group 命名：** 使用 `<leader>X` 作为 group 前缀，描述包含 unicode 图标
2. **描述格式：** `🎯 动词 + 名词` 或 `🎯 功能描述`
3. **Icon 使用：** 所有 group 和常用操作添加 `icon` 字段
4. **排序：** 按字母顺序排列同一 group 下的按键

#### 2.3 统一的 Keymap 布局

```
<leader>  ─── Leader Key
├── b  ── Buffer 管理 📑
│   ├── d  ── Delete Buffer
│   └── D  ── Delete Buffer (Force)
├── c  ── Code 工具 🛠️
│   ├── f  ── Format Buffer
│   ├── m  ── Mason
│   └── r  ── Replace in Files (Spectre)
├── d  ── Debugger (DAP) 🐛
│   ├── b  ── Toggle Breakpoint
│   ├── B  ── Set Cond Breakpoint
│   ├── c  ── Continue
│   ├── i  ── Step Into
│   ├── o  ── Step Out
│   ├── s  ── Close
│   ├── u  ── DapUI Toggle
│   └── v  ── Step Over
├── e  ── File Explorer 📁
├── f  ── Find / Search 🔍
│   ├── Q  ── Quickfix List
│   ├── b  ── Buffers
│   ├── d  ── Diagnostics
│   ├── f  ── Files
│   ├── F  ── File Templates
│   ├── j  ── Jumplist
│   ├── l  ── Line in Buffer
│   ├── m  ── Old Files
│   ├── n  ── Notifications
│   ├── o  ── Old Files
│   ├── p  ── Resume Picker
│   ├── q  ── Location List
│   ├── r  ── Registers
│   ├── t  ── Templates
│   ├── u  ── Undo History
│   ├── w  ── Live Grep
│   ├── W  ── Live Grep Args
│   └── y  ── Yank History
├── l  ── LSP 📡
│   ├── a  ── Code Action
│   ├── d  ── Diagnostic Float
│   ├── i  ── IncRename
│   ├── j  ── Switch Header (clangd)
│   └── r  ── Rename
├── m  ── Markdown ✍️
│   ├── n  ── Toggle Ordered List
│   ├── r  ── Preview
│   ├── u  ── Toggle Unordered List
│   └── U  ── Toggle Unordered (Indent)
├── n  ── Noice 🔔
│   ├── a  ── All
│   ├── h  ── History
│   └── l  ── Last Message
├── r  ── Run / Build ▶️
│   ├── b  ── Smart Build
│   ├── B  ── Select Template
│   ├── c  ── Cancel Running
│   ├── d  ── Dispose All
│   ├── l  ── Rerun Last
│   ├── o  ── Task List
│   ├── q  ── Open Output
│   ├── R  ── Build & Run
│   └── r  ── Run Executable
├── t  ── Tex / Typst 📐
│   ├── U  ── Unpin (Tinymist)
│   └── ... (其他 tex/typst 操作)
├── u  ── Undo Tree 🔄
├── v  ── Edit Vimrc ⚙️
├── w  ── Translate 🌐
└── ... (其他)
```

#### 2.4 带 Unicode 图标的 which-key 描述

| 功能 | 原描述 | 新描述 |
|------|--------|--------|
| Buffer Delete | "Delete Buffer" | "🗑️ Delete Buffer" |
| Format | "Format buffer" | "📝 Format Buffer" |
| Mason | "Mason" | "📦 Mason" |
| Find Files | "Find file" | "🔍 Find Files" |
| Find Buffers | "Find buffers" | "📑 Find Buffers" |
| LSP Code Action | "Lsp code action" | "⚡ Code Action" |
| Diagnostic Float | "Diagnostic float" | "⚠️ Diagnostic Float" |
| Rename | "Lspsaga rename" | "✏️ Rename" |
| IncRename | "IncRename" | "✏️ IncRename" |
| Goto Definition | "Lspsaga goto definition" | "📍 Goto Definition" |
| Goto Reference | "Goto reference" | "📍 Goto Reference" |
| Hover | "Lspsaga Hover" | "💡 Hover" |
| Markdown Preview | "Preview markdown" | "👁️ Preview" |
| Insert Timestamp | "Insert formatted time" | "🕐 Insert Timestamp" |
| DAP Continue | "Continue" | "▶️ Continue" |
| DAP Step Into | "Step into" | "⏬ Step Into" |
| DAP Step Over | "Step over" | "➡️ Step Over" |
| DAP Step Out | "Step out" | "⏫ Step Out" |
| DAP Toggle Breakpoint | "Toggle breakpoint" | "🔴 Toggle Breakpoint" |
| Smart Build | "Smart Build" | "🔨 Smart Build" |
| Run Executable | "Run Executable" | "▶️ Run Executable" |
| Task List | "Task List" | "📋 Task List" |
| Noice History | "Noice History" | "📜 History" |
| Translate | "Translate" | "🌐 Translate" |
| Undo History | "Find undo" | "🔄 Undo History" |
| Yank History | "Find yank history" | "📋 Yank History" |
| Goto Diagnostic | "Lsp next/prev diagnostic" | "⚠️ Next/Prev Diagnostic" |
| Toggle Ordered List | "Toggle ordered list" | "🔢 Toggle Ordered List" |
| Toggle Unordered List | "Toggle unordered list" | "📌 Toggle Unordered List" |
| NvimTree | "NvimTreeToggle" | "📁 File Explorer" |
| Toggle Terminal | "ToggleTerm" | "💻 Toggle Terminal" |
| Spectre | "Replace in files (Spectre)" | "🔀 Replace in Files" |
| View PDF (tex) | "View the PDF" | "👁️ View PDF" |
| Recompile LaTeX | "Recompile LaTeX" | "🔄 Recompile" |
| Run Single File (cpp) | "Run single file" | "▶️ Run File" |
| Jump Forward (luasnip) | *(无描述)* | "⏭️ Jump Forward" |
| Jump Backward (luasnip) | *(无描述)* | "⏮️ Jump Backward" |
| Add Empty Line Above | "Add empty line above" | "⬆️ Add Empty Line Above" |
| Add Empty Line Below | "Add empty line below" | "⬇️ Add Empty Line Below" |
| Move Line Up | "Move line up" | "⬆️ Move Line Up" |
| Move Line Down | "Move line down" | "⬇️ Move Line Down" |
| Edit Vimrc | "Edit personal VIMRC" | "⚙️ Edit Vimrc" |
| Window Resize | "Increase/Decrease window" | "🔲 Resize Window" |
| Toggle Search Highlight | "Toggle search highlight" | "🔍 Toggle Highlight" |
| Paste without overwrite | "Paste without overwriting register" | "📋 Paste (no overwrite)" |
| Yank to End of Line | "Yank to end of line" | "📋 Yank to EOL" |
| Join Lines | "Join lines and restore cursor" | "🔗 Join Lines" |
| Search Visual Selection | "Search visual selection backwards" | "🔍 Search Backwards" |
| Highlight Search | "HLSearch lens" | "🔎 HLSearch" |

---

### 方案 3：Group 层级重组

当前 `<leader>` 下存在以下 **group 命名不一致** 问题：

| 问题 | 现状 | 建议 |
|------|------|------|
| Noice 在 `<leader>n` 下，但 `<leader>fn` 也有 Find notify | 分散 | 将 `<leader>fn` 合并到 `<leader>n`，或保持 `<leader>f` 下 |
| `<leader>nu` (dismiss) 在 notify 插件下但使用 `<leader>n` | 与 Noice 冲突 | 改为 `<leader>nu` 保持，Noice 保持 `<leader>n`（group 不冲突） |
| `<leader>w` 是 Translate，但 `<leader>fw` 是 Find word | 功能分散 | 保持现状（不同 group） |
| `<leader>ft` 是 Templates，但 `<leader>f` 是 Find | 不一致 | 改为 `<leader>ft` 保持（Templates 是查找的一种） |
| `<leader>lm` / `<leader>ln` / `<leader>lc` 是 Literature | 没有 group | 添加 `<leader>l` 为 Literature group？但 `<leader>l` 已被 LSP 占用 |

**推荐方案：**
- `<leader>l` 保留给 LSP（最常用）
- Literature 改为 `<leader>z` 或保持无 group（`<leader>lm` 等独立按键）
- `<leader>fn` 保留在 `<leader>f` 下（Find notify 是查找的一种）

---

### 方案 4：which-key 全局配置增强

当前 `lua/plugins/editor/which_key.lua` 是最简配置，建议增强：

```lua
return {
    "folke/which-key.nvim",
    dependencies = { "echasnovski/mini.icons", version = false },
    opts = {
        icons = {
            group = "▸",        -- Group icon
            separator = " ── ", -- Separator
            keys = {
                Up = "⬆️",
                Down = "⬇️",
                Left = "⬅️",
                Right = "➡️",
                C = "❖",
                M = "✧",
                D = "✦",
                S = "✪",
            },
        },
        preset = "modern",     -- Use modern preset
        win = {
            border = "rounded",
            title = "  Keymap  ",
            title_pos = "center",
        },
        layout = {
            height = { min = 1, max = 25 },
            width = { min = 20, max = 50 },
        },
        delay = function() return 200 end,
        plugins = {\n            marks = true,
            registers = true,
            spelling = {
                enabled = true,
                suggestions = 20,
            },
        },
    },
}
```

---

## 三、实施步骤

### Phase 1：修复时间戳泄漏（优先级：高）
- [ ] 修改 `lua/config/autocmds.lua`，为 `BufWritePre` 添加 `pattern` 过滤

### Phase 2：解决按键冲突（优先级：高）
- [ ] `<leader>mu`：typst 的 Tinymist Unpin 改为 `<leader>tU`
- [ ] `<leader>bd`：tex 的 Bold 改为 `<leader>fb`
- [ ] 创建 `<leader>t` 作为 tex/typst 专用 group

### Phase 3：统一 which-key 规范（优先级：中）
- [ ] 增强 `which_key.lua` 全局配置
- [ ] 为所有 group 添加 icon
- [ ] 统一描述格式（添加 unicode 符号）
- [ ] 按字母顺序排序每个 group 下的按键

### Phase 4：整理重复/不一致的映射（优先级：低）
- [ ] 检查 `<leader>fm` 和 `<leader>fo` 都映射到 `oldfiles` 是否有意为之
- [ ] 统一 `<leader>f` 下的所有 telescope 映射
- [ ] 清理 nvimtree 中重复的 `l` 映射

---

## 四、风险与注意事项

1. **用户习惯：** 按键变更可能影响已有肌肉记忆，建议逐步迁移
2. **Buffer 作用域：** 确保 filetype 特定的 keymap 正确设置 `buffer = buf`
3. **加载顺序：** which-key 必须在 lazy 加载完成后才能注册，确保 `wk.add` 在正确时机执行
4. **图标渲染：** 确保终端和字体支持 unicode 符号（当前已使用 `mini.icons`）
5. **`<leader>bd` 变更影响最大：** Buffer 删除是最常用操作之一，确认 tex 的 Bold 使用频率是否低到可以更换位置

---

## 五、待确认问题

1. `<leader>fm` 和 `<leader>fo` 都指向 `oldfiles`，是有意为之还是遗漏？
2. Literature Manager 的 keymap 是否需要独立的 `<leader>` group？
3. 是否保留 `<leader>fn` 在 Find group 下，还是合并到 Noice group？
4. `<leader>w` (Translate) 是否应该改为 `<leader>tw` 以保持一致性？
5. 对于 `<C-t>` 时间戳插入，是否应该限制只在 insert 模式下生效？（当前已限制）
