# zathura-cite 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** zathura 选中 PDF 文字按 Y → nvim 笔记光标处插入 wikilink 引用；nvim 光标停在引用行按 Enter → zathura 跳页。

**Architecture:** 两个组件 + 一个 drop 目录。zathura 端 `map Y exec` 调 `bin/zath-cite.sh`（读 X 剪贴板里的选中文本，写 `/tmp/zathura-cite/<ts>.txt`）；nvim 端 `plugin/zathura_cite.lua` 轮询 drop 目录、格式化插入，并用 buffer-local `<CR>` dispatcher 覆盖 obsidian.nvim 的 smart_action（引用行走 zathura，其余原样委托）。纯逻辑集中在 `lua/zathura_cite/core.lua`，全部 TDD。

**Tech Stack:** nvim 0.12 Lua 5.1、plenary busted（已在 lazy 中）、sh、xclip、xdotool。无新依赖。

**Spec:** `docs/specs/2026-10-03-zathura-cite-design.md`

## Global Constraints

- 插件落点 `~/.local/share/nvim/site/zathura-cite/`（自包含：`plugin/`、`lua/`、`bin/`、`tests/`）
- drop 目录固定 `/tmp/zathura-cite/`；drop 文件三行：页码 / PDF 绝对路径 / 选中文本（第 3 行起可多行）
- zathura 触发键 `Y`；nvim 反向键 `<CR>`
- 引用格式（vault 内）：`[[<vault相对路径,去.pdf>|<basename>]] p.<N>: "<text>"`；vault 外：`[<basename>](<绝对路径>) p.<N>: "<text>"`
- text 清理：换行/制表符→单空格，去首尾空白
- 只处理 markdown buffer 且文件在 `~/knowledge_library` 内
- X11 only；无配置项

## Review Focus

1. **PDF 文件名含空格**：实测 zathura exec 的 `$FILE` 展开后按空格切 argv，引号无效 → 最终方案：map 只传 `$PAGE`，文件路径从 zathura 窗口标题（全路径，空格安全）取；Task 5 e2e 已用含空格文件名验证通过
2. **Y 前用户又复制了别的内容**：剪贴板已不是选中文本 → 设计接受此风险（spec §2），无代码处理，仅文档说明
3. **多个同名 PDF 的 zathura 窗口**：xdotool 取第一个匹配 → 接受（spec 未要求更智能选择）
4. **wikilink 指向 .md 同名但 PDF 不存在**：match_citation_line 必须返回 nil 回退 obsidian，不得误跳
5. **drop 文件 text 为空**：提示并丢弃，不插入（Task 2/4 测试钉住）

---

### Task 1: core.lua — 文本清理与引用格式化

**Files:**
- Create: `~/.local/share/nvim/site/zathura-cite/lua/zathura_cite/core.lua`
- Test: `~/.local/share/nvim/site/zathura-cite/tests/core_format_spec.lua`

**Interfaces:**
- Produces:
  - `core.clean_text(text: string) -> string`
  - `core.format_citation(page: integer, pdf_path: string, text: string, vault_root: string) -> string`

- [ ] **Step 1: 写失败测试**（tests/core_format_spec.lua；文件头部加 `package.path = "<plugin_dir>/lua/?.lua; " .. package.path`，plugin_dir 用 `vim.fs` 或硬编码绝对路径）

```lua
local core = require("zathura_cite.core")
describe("core.clean_text", function()
  it("joins newlines and tabs to single spaces, trims")
  -- 断言: core.clean_text("a\nb\tc  \n") == "a b c"
  -- 断言: core.clean_text("") == ""
end)
describe("core.format_citation", function()
  local vault = "/home/ls/knowledge_library"
  it("vault-internal pdf -> wikilink without .pdf")
  -- format_citation(3, vault.."/literature/2017_msckf_notes.pdf", "hello", vault)
  --   == '[[literature/2017_msckf_notes|2017_msckf_notes]] p.3: "hello"'
  it("vault-external pdf -> markdown link with abs path")
  -- format_citation(1, "/tmp/x.pdf", "t", vault) == '[x](/tmp/x.pdf) p.1: "t"'
  it("basename keeps no extension")
  -- 上两条已覆盖：display = basename 去 .pdf
end)
```

- [ ] **Step 2: 跑测试确认失败**

Run: `nvim --headless -c "PlenaryBustedDirectory /home/ls/.local/share/nvim/site/zathura-cite/tests/ exit"`
Expected: module 不存在 → FAIL

- [ ] **Step 3: 实现 core.lua 的 clean_text 与 format_citation**

`clean_text`: `text:gsub("[\r\n\t]+", " "):gsub("^%s+", ""):gsub("%s+$", "")`。
`format_citation`: pdf_path 以 vault_root.."/" 开头且去掉前缀后含 ".pdf" → wikilink（rel 去掉尾部 ".pdf"，display = rel 的 basename）；否则 markdown link（display = basename 去 .pdf）。拼接 ` p.N: "text"`。

- [ ] **Step 4: 跑测试确认通过**

Run: 同上。Expected: PASS

- [ ] **Step 5: 不提交**（`site/` 不在任何 git 仓库内；git 化统一在 Task 5 Step 4 做，届时 `site/zathura-cite` 变成指向 config 仓库 `external/zathura-cite` 的 symlink）

### Task 2: core.lua — drop 文件解析与引用行匹配

**Files:**
- Modify: `~/.local/share/nvim/site/zathura-cite/lua/zathura_cite/core.lua`
- Test: `~/.local/share/nvim/site/zathura-cite/tests/core_parse_spec.lua`

**Interfaces:**
- Produces:
  - `core.parse_drop_file(path: string) -> {page:integer, file:string, text:string} | nil`（<2 行或 page 非数字 → nil；text = 第 3 行起 join "\n"，可为 ""）
  - `core.latest_drop(dir: string) -> string | nil`（目录不存在/空 → nil；按文件名时间戳取最新，文件名即 YYYYmmddHHMMSS_NANOS 字典序可用）
  - `core.match_citation_line(line: string, vault_root: string) -> {file:string, page:integer} | nil`（返回 file 为**绝对路径**）
  - `core.find_in_vault(vault_root: string, basename: string) -> string | nil`（vault 内找 basename 唯一命中）
- Consumes: Task 1 无

- [ ] **Step 1: 写失败测试**

```lua
local core = require("zathura_cite.core")
local vault = "/home/ls/knowledge_library"
describe("core.parse_drop_file", function()
  it("parses 3-line file", function()
    -- 写临时文件 "3\n/tmp/a.pdf\nline one\nline two" → {page=3, file="/tmp/a.pdf", text="line one\nline two"}
  end)
  it("empty text -> text==''", function()
    -- "2\n/tmp/a.pdf\n" → ok, text == ""
  end)
  it("malformed -> nil", function()
    -- "x\n" / 空文件 / "1.5\n/tmp/a.pdf" → nil
  end)
end)
describe("core.match_citation_line", function()
  it("matches own wikilink format", function()
    -- '[[literature/2017_msckf_notes|2017_msckf_notes]] p.3: "x"' → {file=vault.."/literature/2017_msckf_notes.pdf", page=3}
    -- 注意：vault 内文件可能不存在（测试机上有，但用虚构路径时 fallback find_in_vault 找不到 → 返回 nil）
  end)
  it("matches markdown link format", function()
    -- '[a](/tmp/b.pdf) p.7: "x"' → {file="/tmp/b.pdf", page=7}（仅当 /tmp/b.pdf 存在）
  end)
  it("no p.N -> nil", function()
    -- '[[literature/2017_msckf_notes|x]] quoted' → nil
  end)
  it("wikilink to .md target -> nil", function()
    -- '[[note/foo|foo]] p.2: "x"' → nil（目标 .md 非 PDF）
  end)
  it("wikilink target not in vault and find fails -> nil", function()
    -- '[[nowhere/ghost|ghost]] p.1: "x"' → nil
  end)
end)
describe("core.latest_drop", function()
  it("returns newest by name, nil when empty", function()
    -- 造两个文件 → 返回时间戳大的；空目录 → nil
  end)
end)
```

解析规则（写入测试注释即可）：
- wikilink: `\[\[([^|\]]+)([|][^\]]*)?\]\]`；target 不含 ".pdf" 时补 ".pdf"；候选绝对路径 = 以 "/" 开头直接用；否则 vault_root .. "/" .. target；**文件必须存在**；不存在 → `find_in_vault(vault, basename)` 唯一命中则用之，否则 nil
- markdown: `\[[^\]]+\]\(([^) ]+\.pdf)\)`；目标必须存在
- page: 行内首个 `p%.(%d+)`

- [ ] **Step 2: 跑测试确认失败** → Run: 同 Task 1 Step 2。Expected: FAIL

- [ ] **Step 3: 实现 parse_drop_file / match_citation_line / find_in_vault**

`find_in_vault`：`vim.fn.system({"find", vault, "-name", basename .. ".pdf", "-type", "f"})` 取首行（多条时仍取首行——spec 接受）；找不到或输出为空 → nil。

- [ ] **Step 4: 跑测试确认通过**

- [ ] **Step 5: 不提交**（同 Task 1 Step 5）

### Task 3: bin/zath-cite.sh 中转脚本

**Files:**
- Create: `~/.local/share/nvim/site/zathura-cite/bin/zath-cite.sh`

**Interfaces:**
- Produces: `zath-cite.sh <page> <file>` → 写 `/tmp/zathura-cite/<YYYYmmddHHMMSS_NANOS>.txt`（三行格式）
- Consumes: X CLIPBOARD（xclip）

- [ ] **Step 1: 写脚本**

```sh
#!/bin/sh
page="$1"; file="$2"
dir="/tmp/zathura-cite"; mkdir -p "$dir"
ts="$(date +%Y%m%d%H%M%S_%N)"
text="$(xclip -o -selection clipboard 2>/dev/null)"
{ printf '%s\n%s\n%s\n' "$page" "$file" "$text"; } > "$dir/$ts.txt"
```

- [ ] **Step 2: 手动验证**

Run: `printf 'hello world' | xclip -selection clipboard && sh ~/.local/share/nvim/site/zathura-cite/bin/zath-cite.sh 3 /tmp/a.pdf && cat "$(ls -t /tmp/zathura-cite | head -1 | sed "s|^|/tmp/zathura-cite/|")"`
Expected: 三行 = `3` / `/tmp/a.pdf` / `hello world`

- [ ] **Step 3: 不提交**（同 Task 1 Step 5）

### Task 4: plugin/zathura_cite.lua — 装配

**Files:**
- Create: `~/.local/share/nvim/site/zathura-cite/plugin/zathura_cite.lua`
- Test: `~/.local/share/nvim/site/zathura-cite/tests/plugin_spec.lua`

**Interfaces:**
- Consumes: Task 1-3 全部
- Produces:
  - `zc.install_zathurarc(zathurarc_path: string, script_path: string) -> boolean`（已含本行→false 不写；否则追加 `map Y exec <script>\ $FILE\ $PAGE` → true）
  - `zc.consume(drop_dir, insert_fn) -> boolean`（insert_fn(text) 由插件侧注入 buffer 插入逻辑 → 可测）
  - 命令：`:ZathuraCiteLatest` `:ZathuraCiteJump`
  - buffer-local `<CR>` dispatcher

- [ ] **Step 1: 写失败测试**

```lua
describe("install_zathurarc", function()
  it("appends once, idempotent", function()
    -- tmp 文件为空 → true，文件含 "map Y exec <script>\\ \$FILE\\ \$PAGE"
    -- 再跑 → false，文件内容不变
  end)
end)
describe("consume", function()
  it("inserts latest drop, deletes file, skips empty text", function()
    -- 规则：取 latest_drop；若 text=="" → 删文件+提示+return false；否则 insert_fn(citation)+删文件+return true
    -- 测试 1: 最新文件 text 为空 → false，文件已删，insert_fn 未被调用
    -- 测试 2: 最新文件正常 → true，insert_fn 收到完整引用串，文件已删
  end)
end)
```

- [ ] **Step 2: 跑测试确认失败**

- [ ] **Step 3: 实现插件主体**

装配逻辑（顺序）：
1. `vim.g.zathura_cite_vault = vim.fn.expand("~/knowledge_library")`（非目录 → 整个插件 no-op）
2. 启动时 `install_zathurarc(vim.fn.expand("~/.config/zathura/zathurarc"), <本目录>/bin/zath-cite.sh)`；写了则 `vim.notify` 一行
3. 两个 autocmd 都调同一个 `set_cr_dispatcher(buf)`（函数体相同，后挂的覆盖前者，幂等无副作用）：
   - `User ObsidianNoteEnter`（保证晚于 obsidian.nvim 的 keymap 注册）
   - `FileType markdown` 且文件在 vault（兜底 obsidian.nvim 缺席的情况）
   `set_cr_dispatcher` = `vim.keymap.set("n", "<CR>", dispatcher, {expr=true, buffer=true})`
4. dispatcher 函数体：`local m = core.match_citation_line(vim.api.nvim_buf_get_lines(0,-1,-1,true)[vim.api.nvim_win_get_cursor(0)[1]], vault)`；m 非 nil → `jump(m)`（xdotool search --name basename → windowactivate + `key --window W <N> G`；无窗口 → `vim.fn.jobstart` 开 `zathura -P N file`）返回 `"0"`（吞掉 CR）；m 为 nil → `pcall(require,"obsidian.actions").smart_action` 有则返回其结果，否则 `"<CR>"`
5. 500ms `vim.uv.new_timer` 循环：仅当当前 buffer ft=="markdown" 且文件在 vault 且 drop 目录非空时 `consume()`；insert_fn = 在光标处 `vim.api.nvim_put` 单行 + 光标移到行尾
6. 命令定义（`vim.api.nvim_create_user_command`）：`:ZathuraCiteLatest` = consume；`:ZathuraCiteJump` = 对光标行跑 match+jump

- [ ] **Step 4: 跑测试确认通过**（busted 里测 install_zathurarc / consume / latest_drop；autocmd/jobstart 部分不测）

- [ ] **Step 5: 不提交**（同 Task 1 Step 5）

### Task 5: E2E 验证 + git 化

**Files:**
- Modify: `~/.config/nvim/`（新增 `external/zathura-cite/` 目录跟踪插件源码）
- Modify: `~/.config/zathura/zathurarc`（插件自动追加，人工确认）

- [ ] **Step 1: 正向 e2e**

开 zathura（普通方式，非 -c 临时目录）→ 选中文本按 Y → 回 nvim（vault 内 md 光标就位）→ 500ms 内出现引用。核对：wikilink 路径、页码、文本。
- [ ] **Step 2: 空格文件名 e2e**（Review Focus #1）

`cp /home/ls/knowledge_library/literature/2017_msckf_notes.pdf "/tmp/a b.pdf"` → zathura 开它 → 选中 Y → 核对 drop 文件 file 行完整（若 word-split → 改 zathurarc 行为 `map Y exec sh\ -c\ 'script\ \"\$FILE\"\ \"\$PAGE\"'` 等价方案并重测）
- [ ] **Step 3: 反向 e2e + 共存回归**（Review Focus #4）

光标在 Step 1 插的引用行按 CR → zathura 跳页（先已开、再 pkill 后重开两遍）；光标在普通 `[[note/...]]` 链接按 CR → 仍走 obsidian follow_link；空白行 CR 正常
- [ ] **Step 4: 插件源码 git 化**

```bash
cp -r ~/.local/share/nvim/site/zathura-cite ~/.config/nvim/external/zathura-cite
rm -rf ~/.local/share/nvim/site/zathura-cite
ln -s ~/.config/nvim/external/zathura-cite ~/.local/share/nvim/site/zathura-cite
```

运行位置不变（nvim 经 symlink 加载），源码进 config 仓库随 git 同步
- [ ] **Step 5: 提交**

```bash
cd ~/.config/nvim
git add external/zathura-cite
git commit -m "feat(zathura-cite): zathura↔nvim 双向 PDF 引用——Y 插入 wikilink 引用，CR 跳页"
```

- [ ] **Step 6: 报告**：向用户报告装了哪几个文件、zathurarc 加了哪行、E2E 结果（含空格文件名结论）、分支 `feat/zathura-cite` 待合并
