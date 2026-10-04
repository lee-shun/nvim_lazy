# AGENTS.md — 本 nvim 配置的协作标准

> 给所有参与整理/开发本配置的 AI agent（和人类维护者）。内容来自实际踩坑记录，每条都有真实事故或实验支撑。改配置前先读完 §3 §4。

## 1. 环境事实（以此为准，不要假设）

| 项 | 值 |
|---|---|
| Neovim | **0.12.4**（0.11+ API；0.12 有破坏性变更，见 §4.1） |
| 配置目录 | `/home/ls/.config/nvim`（git 仓库；提交按逻辑批次 + 清晰 message，日常推 `lan`） |
| 插件目录 | `~/.local/share/nvim/lazy/`（插件源码本地可查，**优先查这里**） |
| nvim 运行时文档 | `/usr/local/share/nvim/runtime/doc/` |
| lazy.nvim 源码 | `~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/`（spec 字段看 `core/types.lua`，加载看 `core/loader.lua`/`meta.lua`/`plugin.lua`） |
| Rust/cargo | **本机没有**（blink.cmp frecency 因此关闭；别加需要 Rust 的插件） |
| AI 服务 | 局域网（`NVIM_AI_HOST` 覆盖，默认 `192.168.1.105`）：ollama `:11434`、llamacpp `:8080/v1`（llama-swap 路由）；本机 llama-server `127.0.0.1:8080`（Qwen2.5-Coder-3B，OpenAI 兼容 API，FIM `/infill` 常未运行）。注意：avante/opencode 配置里 `api_key_name="TERM"` 很可疑（TERM 是终端类型变量），本地 llama.cpp 不校验 key 所以能跑，换真 API 前必须改 |
| ⚠️ 拉模型限制 | **用户拍板：不要用 105 对应的局域网网口/链路拉取大模型**（ollama registry 下载走局域网时连接不稳）；模型一律走其他途径（本机已有模型、直连官方源等） |
| 本机翻译栈 | **transdog.nvim**（替换已死的 vim-translator）：sdcv 查词 + 本地 AI 翻译。① sdcv 免 root 装在 `~/.local/bin/sdcv`（Ubuntu deb 解包），词典 `~/.stardict/dic/`（ECDICT 340 万词条）；② **ollama 未安装**（用户拍板不装，模型 registry 连接不稳）；③ **走 shim**：`assist/ollama_shim.py`（仓库内，Ollama `/api/generate` → OpenAI chat）由 systemd **user** 服务 `ollama-shim.service`（`~/.config/systemd/user/`）托管，监听 `127.0.0.1:11434` 转发到 llama-server `:8080`（Qwen2.5-Coder-3B，会多嘴但可用）。transdog 的 `ollama_host` 指 11434、`ollama_model` 名字无所谓（shim 忽略） |
| 用户 | CASIA（中科院自动化所），SLAM/VIO/ROS2/无人机方向；**注释和提示文案用中文** |
| LSP 测试文件 | `/tmp/lsp_test/`（t.cpp+t.h、test.tex、note.md、ts.md） |
| git 远程 | `origin`=github `lee-shun/nvim_lazy`、`lan`=`shun@192.168.1.135:Shun/nvim_config.git`。当前工作分支 **`try/treesitter-main`**（treesitter 迁移实验，验证后合回）；历史分支：`new`（旧工作分支）、`feat/zathura-cite`、`master`/`dev`。gitee `liangshun-dev/config` 本机无凭据，推不了 |
| 远程机器 61 | `lee@30.221.130.61`，网络常超时；61 上没有 `~/knowledge_library`（相关插件用 `cond` 自动禁用，见 §2） |
| 知识库 | `~/knowledge_library`（2.4G git repo，仅本机） |
| 未安装的插件 | **snacks.nvim 不在配置里**（`~/.local/share/nvim/snacks` 是残留数据目录）；buffer 管理=barbaric+telescope buffers；通知=noice |

## 2. 配置结构

```
init.lua                  → 版本检查（<0.11 退出）+ require("config").setup()
lua/config/               → init / options / lazy / autocmds / keymaps
lua/plugins/{coding,editor,ui,ai,writing,run}/*.lua
                          → lazy spec；目录扫描加载（子目录无 init.lua，新增文件即生效）
lua/util/                 → 自研：build（构建/运行）、wrap（LaTeX 包裹）、lsp（on_attach+LSP 键位）、project
lua/lang/                 → FileType 分发：markdown / tex / cpp / python / typst
snip/  template/          → LuaSnip snippets（VSCode 格式）+ vim-templates 模板
spell/en.utf-8.add        → 用户词库（改后必须删 .spl 缓存，见 §4.4）
assist/latexindent.yaml   → 手动用（conform 走 tex-fmt，不读它）
tmp/                      → gitignored；跨会话状态写 tmp/nvim-improvement-state.md
```

**关键链路（改动前先理解）：**
- **LSP 键位**（ga/gr/gn/gi/gt/gx/gd/gD/gh/gH、`<leader>lf/li/l[/l]`）由 `util/lsp.lua` on_attach 经 which-key 注册。on_attach 之前抛错的任何代码会**静默杀掉全部 LSP 键位**（症状"很多按键不行了"，日志 `LSP[xxx]: Error ON_ATTACH_ERROR`）。
- **大文件处理**（`config/autocmds.lua` 末段，Lua 版替代已删的 LargeFile.vim）：≥1.5MB 或平均行长>1000 → 关 swap/backup/undo/syntax/folds + 全局 `ei="FileType"`（挡掉 ftplugin/语法/treesitter/ft 触发的懒加载）；按窗口生效；`:Unlarge` 恢复+`doautocmd FileType` 补跑，`:Large` 强制启用。
- **treesitter 已迁移 main 新 API**（分支 `try/treesitter-main`，2026-10）：
  - 旧 API（master 分支的 `highlight`/`ensure_installed`）已废弃——**master 分支上游已归档**（2025-05），main 是完全重写且要求 Nvim 0.12+。
  - 新写法：`lazy=false` + `build=":TSUpdate"` + `setup{}` + `install{langs}`（langs 只能放 **parser 名**，不能放 filetype 如 `sh`）+ FileType autocmd 里 `vim.treesitter.start(buf, lang)` 按语言开高亮。
  - parser/queries 装到 `stdpath('data')/site`（parser/、queries/ 等目录）。
  - filetype≠parser 名时 autocmd 里显式映射（`sh→bash`），否则每次打开报 "skipping unsupported language" warning。
  - 高亮/解析本身由 Nvim 0.12 内置 `vim.treesitter` API 完成，**依赖 treesitter 的第三方插件（ibl、rainbow-delimiters、hlargs、mini.ai、Comment、illuminate…）都只依赖内置 API + parser，与 nvim-treesitter 插件版本无关**。
  - ⚠️ **lazy.nvim 不校验 lock commit 是否属于声明的 branch**：曾出现 lazy-lock 写 `branch="master"` 但 commit 是 main 的（实际一直跑 main 代码、旧配置项被静默忽略）。改 branch 后必须核对 lock 与 `git branch -r --contains` 一致。
- **跨机器插件守护**：数据路径可能缺失的插件用 `cond = vim.fn.isdirectory(expand("~/xxx")) == 1`（obsidian 对 knowledge_library 如此）——路径缺失整体禁用不报错，建好后自动生效。
- **snippet**：LuaSnip 独立 spec（`InsertEnter` 自持）；blink.lua 里的 `"L3MON4D3/LuaSnip"` 依赖边**不能删**（加载顺序保险）。
- **构建/运行**：`buildrun` 是 `virtual=true` 本地插件（不安装、不加 rtp），`<leader>r*` 触发，依赖 toggleterm。
- **tex**：conceal 全局关（`conceallevel=0` + `vimtex_syntax_conceal_disable=1`）；`vimtex_syntax_enabled=0`（无高亮，用户已知）。vimtex 必须 eager 加载（zathura headless 反搜要 `:VimtexInverseSearch`）。
- **键位约定**：`mapleader=" "`，**`maplocalleader=","`**（markdown-plus 等 buffer 局部键都是 `,x` 开头；其表格键前缀也统一为 `,t`）。insert 弹框导航全交给 blink.cmp（勿再加全局 `<cr>`/`<Tab>` expr 映射，曾因此产生 S-Tab bug）。
- **有意保留的冗余**（用户拍板，别顺手清理）：spectre+live_grep、vista+lspsaga（lspsaga 只留 winbar/diagnostic/action）、ibl+rainbow-delimiters+indent-rainbowline 三者、AI 四件套（avante/pi/llama.vim FIM/opencode 已禁用）。已删：undotree（用 telescope-undo `<leader>fu`）、mini.bufremove（用 telescope buffers `<leader>fb`+picker 内 `<leader>d`）。

## 3. 验证方法（headless 套路，全部踩过）

### 3.1 启动检查
```bash
nvim --headless -c "echo 'CONFIG_OK'" -c "qa!"
```
⚠️ 不打开文件时 BufReadPre/FileType/BufNewFile 触发的插件不加载，config 函数内的错误会漏检。坏 spec 启动即报错（lazy 启动时校验），免费检查。

### 3.2 LSP / 文件相关测试（必须开真实文件 + 等待）
```bash
cd /tmp/lsp_test && nvim --headless t.cpp -c "sleep 8" -c "lua
io.write('clients: ', #vim.lsp.get_clients({bufnr=0}), '\n')" -c "qa!"
```
- `sleep 8` 等 LSP 附加，否则 clients 为空；ON_ATTACH_ERROR 直接看 stderr。
- 验证按 filetype 的行为（如 treesitter 高亮）：**filetype 名可能与直觉不同**（bash 脚本是 `sh`）；用 `vim.cmd("doautocmd FileType <ft>")` 可手动触发。
- 断言 treesitter 高亮：`vim.treesitter.highlighter.active[buf] ~= nil`。
- 手动加载懒插件再断言：`require('lazy').load({plugins={'插件名'}, nowait=true})`（lazy 的 require 钩子会触发加载，但显式 load 更稳）。

### 3.3 键位测试
- 全局键位 `nvim_get_keymap('n')`；buffer-local 用 `nvim_buf_get_keymap`。
- **headless 下 `normal! <Space>xx` 不触发空格开头键位**（headless 通病）。直接调 callback：遍历 keymap 表找 `lhs` 匹配项调 `k.callback()`（lazy 回调同步加载插件）。
- **which-key 的 `wk.add()` 只入队**，VimEnter 后才消费；headless `-c` 在 VimEnter 前执行，直接断言必为空（曾因此误判 `<leader>mr` 没注册）。正确做法：`nvim_create_autocmd('VimEnter',{once=true,...})` 内再 `defer_fn` 后断言（`vim.wait` 不够，schedule 的 load 要事件循环）。
- 插件状态：`require("lazy").plugins()`（**是函数**），`p._.loaded` / `p._.installed`。

### 3.4 headless 命令陷阱
- `-c` 最多 **10 个**（11 个报错）；多步合并进一个 `-c "lua ..."` 块（autocmd 同步，块内无需 sleep）。
- `io.write` 不接受 boolean（用 `tostring`）。
- **`silent!` 吞错**——先不加跑一遍确认命令有效。
- `nvim_open_win` headless 必须给 `split` 或 `relative`（默认 float 会报错）。
- window ID 动态，用 `nvim_list_wins()`。
- autocmd 同步触发，`lua` 块里 `vim.cmd` 后直接断言。
- `:enew [file]` 无效（E488）；同窗口换 buffer 用 `:edit`。
- 批量语法检查：`load()` 每个改过的文件（一个命令批量做）。

### 3.5 改动后验证清单
1. 改过的 lua 文件全部 `loadfile` 语法检查。
2. `CONFIG_OK` 启动检查。
3. 开真实文件的功能检查（LSP 附加、键位、autocmd 效果、高亮）。
4. 用户可感知行为（键位/显示/AI）→ 明确告诉用户要试哪几个操作。

## 4. 踩坑清单（每条有事故记录）

### 4.1 Neovim API（0.11/0.12）
1. `nvim_create_user_command`：0.12 移除 `buffer` 选项（传了报 `invalid key: buffer`）；本机 build 只支持 3 参数形式 `(name, fn, opts)`，table spec 报 `Expected 3 arguments`。做法：命令全局定义一次，回调里 `nvim_get_current_buf()` 取 buffer。若在 on_attach 里触发会杀全部 LSP 键位。
2. `vim.lsp.util.make_position_params()` 必须传 `position_encoding`（0.12）。只需 TextDocumentIdentifier 的请求直接 `{ uri = vim.uri_from_bufnr(bufnr) }`。
3. **`vim.treesitter.start(buf, lang)`**：0.12 签名是 (buf, lang字符串)，没有 opts 表；`start({lang=x})` 会把 table 当 bufnr 报错。
4. `conceallevel`/`concealcursor` 自 0.11 起 **window-local**；`vim.go` 对它读写都不可靠（设窗口值污染 `vim.go` 读取，`vim.go` setter 不影响新窗口）。要"全局默认"时在任何改动前先捕获。
5. `foldmethod`/`foldenable` **window-local**：`vim.bo[buf].foldmethod` 直接报错；用 `vim.wo`，多窗口每窗显示该 buffer 时重新应用（BufEnter/WinEnter）。
6. **`eventignore` 是忽略列表不是白名单**：`ei="FileType"` = 只忽略 FileType，其他事件照常。恢复后 `doautocmd FileType` 补跑（`:doautocmd` 不受 ei 影响）。
7. `nvim_buf_get_keymap()` 只返回 buffer-local；全局用 `nvim_get_keymap()`。
8. 0.12 事件顺序：FileType 先于 BufWinEnter（依赖 filetype 的 autocmd 用 BufWinEnter 安全）。
9. `vim.o.x = v` 只影响当前窗口（window-local 选项），不是全局默认。
10. `vim.bo.name` 不存在 → `nvim_buf_get_name(0)`。
11. Lua 表下标 0 ≠ 当前 buffer：自己维护 `saved[bufnr]` 表时入口必须 `nvim_get_current_buf()` 解析（曾致 `:Unlarge` 报错）。
12. 对最后一个已加载 buffer `bdelete!` 会让 nvim 重载另一 unloaded buffer（BufReadPre 重触发）——多窗口测试先确认当前 buffer 是谁再断言。
13. 区分"请求失败"与"结果为空"：LSP err 回调里 err 非空=传输/协议失败（ERROR+inspect），err 空但 result 空=业务无结果（WARN）。

### 4.2 lazy.nvim
14. **本地插件用 `virtual=true`**：`{"name", virtual=true, keys={...}, config=...}`——不安装、不加 rtp、config 照跑。**不要自指 `dir`**（非插件目录会被加进 rtp，插件名变目录名）。
15. `lazy=true` 且无触发器（keys/cmd/event/ft）= **永不加载**（除非被别的 spec 依赖）。删依赖边前确认它不是唯一加载路径（曾差点删掉 blink→LuaSnip 那条）。
16. 依赖边 = 加载顺序保证（A 的 dependencies 里的 B 一定先于 A config）。
17. lazy 启动不把所有插件注入 `package.path`：config/回调里 `require("插件.module")` 前必须确保其已加载（声明为真实 dependency）。
18. `require("lazy").plugins` 是函数。
19. **删插件删三处**：spec 文件 + `lazy-lock.json` 条目 + `lazy/<name>` clone（多机器每台；clone 可能几十 MB）。lock 条目启动时自动清，clone 不会。
20. `cond` 启动时求值，适合路径守护；用 `vim.fn.expand("~/...")` 别猜 HOME。
21. **lock 不校验 branch**：改 spec branch 后必须核对 lazy-lock 的 branch/commit 与实际检出一致（`git branch -r --contains <commit>`）。

### 4.3 插件选项
22. **选项名对照插件当前源码**，不凭记忆/旧文档。实例：`g:tex_conceal` 是旧 vimtex 选项，当前源码零引用；当前是 `vimtex_syntax_conceal`(dict)+`vimtex_syntax_conceal_disable`。
23. 注意选项联动：`vimtex_syntax_enabled=0` 关的是**全部高亮**不只 conceal。改选项前 grep 插件源码看它控制什么。
24. 全局注册的插件（noice/blink/lualine/illuminate/yanky…）无通用卸载 API，per-buffer 禁用要插件自己支持。大文件场景重的东西（LSP/treesitter/语法/ft 插件/undo/swap）全是 ft 触发或可选项，`ei=FileType`+显式关选项已覆盖；gitsigns 自带 `max_file_length`。别为长尾造通用开关。
25. telescope：setup 的 `extensions={}` 是官方支持的扩展配置方式；默认值选项（winblend/sorting_strategy/selection_strategy/generic_sorter/vim_buffer_cat previewer 等）写了等于没写，别堆。

### 4.4 数据文件
26. **JSON 字符串内裸换行 = 整个文件非法**，LuaSnip **静默跳过整个文件**（全部 snippet 失效无报错）；多行内容 `\n` 转义，改完 `vim.json.decode` 验证。
27. JSON/lua 表重复键静默后者胜。
28. spell 改 `en.utf-8.add` 后删 `en.utf-8.add.spl` 否则不生效。

### 4.5 Lua 语法
29. `{...}[k]`（table constructor 直接下标）**不合法**，先存局部变量再索引。

## 5. 工作方法论

### 5.1 动手前
- **先读实际现状**，不信任记忆/摘要/上一轮结论（至少两次"记忆"被源码推翻：luasnip 加载路径、tex_conceal）。
- 判断顺序：**nvim 运行时文档 → 插件本地源码 → headless 实验 → 最后 web 搜索**。
- 查选项作用域：`grep -A2 "'选项'" /usr/local/share/nvim/runtime/doc/options.txt`；查插件行为：`grep -rn "选项" lazy/<plugin>/`；查 API 是否存在：直接 headless 调用（报错即文档）。

### 5.2 动手时
- **警惕静默失败**：死选项、非法 JSON、`silent!` 吞错、lock 与 branch 不一致——没有报错只有功能悄悄没了。验证"功能在"，不只是"没报错"。
- 修 bug 分三层：语法错（loadfile）/加载错（启动检查）/运行时错（开真实文件）。
- 外部依赖环境变量化，默认值保持现状：`os.getenv("NVIM_XXX") or "原值"`。

### 5.3 收尾
- 提交：逻辑批次一个 commit，message 写"改了什么+为什么"；用户确认范围后再动手，"先不用"的部分写进状态文件不顺手做。
- 状态文件 `tmp/nvim-improvement-state.md`（gitignored）：多批次任务每批更新（环境/已完成含验证/待办/用户明确不做的遗留）。上下文压缩后先读它。
- 并行协作：同一工作区同一时间只一个 agent 写文件；并行用 worktree；改完 `git status` 必须干净（除 tmp/）。
- 用户可感知改动：headless 验证通过后**明确告诉用户要试哪几个操作**。
