# AGENTS.md — 本 nvim 配置的协作标准

> 给所有参与整理/开发本配置的 AI agent（和人类维护者）。
> 内容来自实际踩坑记录，每条都有真实事故或实验支撑。改配置前先读完 §3 和 §4。

## 1. 环境事实（不要假设，以此为准）

| 项 | 值 |
|---|---|
| Neovim | **0.12.4**（0.11+ API；0.12 有破坏性变更，见 §4.1） |
| 配置目录 | `/home/ls/.config/nvim`（git 仓库，提交用逻辑批次 + 清晰 message） |
| 插件目录 | `~/.local/share/nvim/lazy/`（所有插件源码本地可查，**优先查这里**） |
| nvim 运行时文档 | `/usr/local/share/nvim/runtime/doc/`（options.txt / lsp.txt / autocommand.txt / lua.txt） |
| lazy.nvim 源码 | `~/.local/share/nvim/lazy/lazy.nvim/lua/lazy/`（spec 字段看 `core/types.lua`，加载看 `core/loader.lua`、`core/meta.lua`、`core/plugin.lua`） |
| Rust/cargo | **本机没有**（blink.cmp 的 frecency 因此关闭；别加需要 Rust 的插件） |
| AI 服务 | 局域网 host 可用 `NVIM_AI_HOST` 覆盖（默认 `192.168.1.105`）：ollama `:11434`、llamacpp `:8080/v1`（llama-swap 路由，模型按需加载）；本机 FIM `127.0.0.1:8080/infill`（**常未运行**，llama.vim 的 auto_fim 会打空请求） |
| 用户 | CASIA（中科院自动化所），SLAM/VIO/ROS2/无人机方向；**注释和提示文案用中文** |
| LSP 测试文件 | `/tmp/lsp_test/`（t.cpp + t.h 配对、test.tex、note.md、ts.md） |
| git 远程 | `origin` = github `lee-shun/nvim_lazy`、`lan` = `shun@192.168.1.135:Shun/nvim_config.git`；**工作分支是 `new`**（不是 main/master，`git push origin main` 会报 "refspec does not match any"）。gitee `liangshun-dev/config` **本机无凭据**（ssh known_hosts 无条目、无 https credential），推不了 |
| 远程机器 61 | `lee@30.221.130.61`，网络常超时；同步配置要等它可达。61 上没有 `~/knowledge_library` |
| 知识库 | `~/knowledge_library`（2.4G git repo，只在本地 ls 机器上） |
| 未安装的插件 | **snacks.nvim 不在配置里**（`~/.local/share/nvim/snacks` 只是残留数据目录）；buffer 管理用 vim-barbaric；通知用 noice；别凭印象认为有 snacks |

## 2. 配置结构

```
init.lua                      → 版本检查（<0.11 退出）+ require("config").setup()
lua/config/                   → init / options / lazy / autocmds / keymaps
lua/plugins/{coding,editor,ui,ai,writing,run}/*.lua
                              → lazy spec；import 走目录扫描（子目录没有 init.lua，
                                新增 spec 文件即生效，不需要注册）
lua/util/                     → 自研：build.lua（构建/运行）、wrap.lua（LaTeX 包裹）、
                                lsp.lua（on_attach + which-key 注册 LSP 键位）、project.lua
lua/lang/                     → FileType 分发：markdown / tex / cpp / python / typst
snip/                         → VSCode 格式 snippets，LuaSnip from_vscode 加载
template/                     → vim-templates 语法的模板
spell/en.utf-8.add            → 用户词库（SLAM/ROS/深度学习术语）
assist/latexindent.yaml       → 手动用（conform 走 tex-fmt，不读这个文件）
tmp/                          → gitignored；跨会话状态写 tmp/nvim-improvement-state.md
```

关键链路：
- **LSP 键位**（ga/gr/gn/gi/gt/gx/gd/gD/gh/gH、`<leader>lf/li/l[/l]`）由 `util/lsp.lua` 的 `on_attach` 经 which-key 注册。任何在 on_attach 之前抛错的代码（如坏的 user_command）会**静默杀掉全部 LSP 键位**——用户症状是"很多按键不行了"，日志在 `LSP[xxx]: Error ON_ATTACH_ERROR`。
- **大文件处理**在 `lua/config/autocmds.lua` §11（Lua 版，替换了原 `after/plugin/LargeFile.vim`，已删）：阈值 1.5MB 或平均行长 >1000 → 关 swap/backup/undo/syntax/folds/matchparen + `ei=FileType`（顺带挡掉 ftplugin/语法/treesitter/ft 触发的懒加载插件）；全局选项按窗口生效；`:Unlarge` 恢复 + `doautocmd FileType`（手动重新加载），`:Large` 强制启用。
- **treesitter 锁 `branch = "master"`（旧版 API）**：main 分支是完全重写，`highlight`/`ensure_installed` 会被**静默忽略**（spec 里有注释）。旧版靠 FileType autocmd attach 高亮，所以能被 `ei=FileType` 挡住。
- **跨机器插件守护**：数据路径在某台机器可能不存在的插件用 lazy `cond = vim.fn.isdirectory(expand("~/xxx")) == 1`（obsidian 对 knowledge_library 就是这么做的）——路径缺失时整体禁用不报错，路径建好后自动生效，零维护。
- **snippet**：LuaSnip 独立 spec（`event = "InsertEnter"` 自持）；blink.lua 里的 `"L3MON4D3/LuaSnip"` 依赖边**不能删**（加载顺序保险：blink 的 snippets preset 依赖 LuaSnip 先加载）。
- **构建/运行**：`buildrun` 是 `virtual = true` 本地插件（不安装、不加 rtp），`<leader>r*` 键位触发，依赖 toggleterm。
- **tex**：conceal 全局关闭（`conceallevel = 0` + `vimtex_syntax_conceal_disable = 1`），用户要原始符号；`vimtex_syntax_enabled = 0`（无高亮，用户已知）。

## 3. 验证方法（headless 测试套路）

### 3.1 基本启动
```bash
nvim --headless -c "echo 'CONFIG_OK'" -c "qa!"
```
⚠️ **不打开文件时，BufReadPre / FileType / BufNewFile 触发的插件不会加载**——spec 里的运行时错误（config 函数内）漏检。坏 spec 会在启动时报错（lazy 启动时校验 spec），这是免费的检查。

### 3.2 LSP 测试（必须打开真实文件 + sleep）
```bash
cd /tmp/lsp_test && nvim --headless t.cpp -c "sleep 8" -c "lua
local cs = vim.lsp.get_clients({ bufnr = 0 })
io.write('clients: ', #cs, '\n')
" -c "qa!"
```
- `sleep 8` 等 clangd 附加；没有 sleep 时 get_clients 为空。
- 检查 ON_ATTACH_ERROR：看 stderr，有错误会直接打印。

### 3.3 键位测试
- 查键位：`vim.api.nvim_get_keymap('n')`（**全局**键位；`nvim_buf_get_keymap` 只返回 buffer-local）。
- **headless 下 `normal! <Space>xx` 不触发空格开头的键位**（对照实验证实是 headless 通病，非配置问题）。正确做法：直接调 keymap 的 callback 函数：
  ```lua
  for _, k in ipairs(vim.api.nvim_get_keymap('n')) do
      if k.lhs == ' rt' and k.callback then k.callback() break end
  end
  ```
  lazy 的键位回调会同步加载插件（`Loader.load` 是同步的），随后 `nvim_feedkeys` 重放按键。
- 查插件状态：`require("lazy").plugins()`（**是函数**，不是表）；`p._.loaded` / `p._.installed` / `p._.is_local`。

### 3.4 which-key 注册的键位：必须等 VimEnter

`wk.add()` 只是**入队**（`lua/which-key/init.lua` 的 `M.add` → `M._queue`），队列只在 `config.setup()` 的 load 里消费一次——启动时 load 被 defer 到 **VimEnter**（`vim_did_enter == 1` 才立即跑）。而 headless 的 `-c` 命令在 **VimEnter 之前**执行，此时断言键位必然为空（曾因此误判"`<leader>mr` 没注册"，实际交互中一切正常）。正确做法：
```bash
nvim --headless -u ~/.config/nvim/init.lua file.md -c "
lua vim.api.nvim_create_autocmd('VimEnter', {once=true, callback=function()
  vim.defer_fn(function()
    -- 这里断言键位（vim.wait 不够，schedule 的 load 需要事件循环）
    vim.cmd('qa!')
  end, 300)
end})
" 2>&1 | grep -v clipboard
```

### 3.5 headless 命令注意事项（全部踩过）
- `-c` 参数**总共最多 10 个**（实测 10 个 OK、11 个报 "Too many ... command arguments"）；多步操作合并进**一个** `-c "lua ..."` 块（lua 块内用 `vim.cmd` 分步，autocmd 是同步的，不需要 sleep）。
- `io.write` **不接受 boolean**（要 `tostring(x)`），接受 string/number。
- **`silent!` 会吞掉命令错误**——先不加 `silent!` 跑一遍确认命令有效。
- `nvim_open_win` 在 headless 下必须给 `split = 'right'` 或 `relative`（否则默认 float，报 "Required: 'relative' or 'external'"）。
- **window ID 是动态的**（不是 1/2/3），用 `vim.api.nvim_list_wins()`。
- autocmd 是同步触发的，`lua` 块里 `vim.cmd(...)` 之后直接断言即可，不需要 sleep。
- `:enew [file]` 是**无效命令**（E488 Trailing characters，enew 不接受文件名）；同窗口换 buffer 用 `:edit`。

### 3.6 改动后验证清单
1. 每个改过的 lua 文件 `loadfile` 语法检查（一个 headless 命令批量做）。
2. `CONFIG_OK` 启动检查。
3. 打开真实文件的功能检查（LSP 附加、键位、autocmd 效果）。
4. 涉及用户可感知的行为（键位、显示、AI）→ 让用户在真实 UI 过一遍。

## 4. 踩坑清单（按类别，每条都有事故记录）

### 4.1 Neovim API（0.11/0.12 变更）
1. **`nvim_create_user_command` 移除了 `buffer` 选项**（0.12）。传了报 `invalid key: buffer`，且若在 on_attach 里触发会杀掉全部 LSP 键位。做法：全局命令定义一次，回调里 `vim.api.nvim_get_current_buf()` 取当前 buffer。
1b. **本机 0.12.4 build 的 `nvim_create_user_command` 只支持 3 参数形式** `(name, fn, opts)`；传 table spec（`{name=..., callback=...}`）报 `Expected 3 arguments`。别信"0.11+ 新 API 通用"，以本机实测为准。
1c. **`foldmethod` / `foldenable` 是 window-local**（`vim.bo[buf].foldmethod = ...` 直接报 `'buf' cannot be passed for window-local option`）。要 `vim.wo`，且多窗口场景下每个窗口显示该 buffer 时要重新应用（BufEnter/WinEnter 回调）。
1d. **Lua 表下标 `0` 不是"当前 buffer"**：`vim.bo[0]` 是 API 约定，但 `my_table[0]` 只是 key 0。自己维护 `saved[bufnr]` 之类的表时，入口必须 `api.nvim_get_current_buf()` 解析成真实编号（曾因此 `:Unlarge` 报"未处于大文件模式"）。
1e. **`eventignore` 的语义是"忽略列表"，不是"白名单"**：`vim.o.ei = "FileType"` = 只忽略 FileType 事件（跳过 ftplugin/语法/treesitter/ft 触发的懒加载插件），其他事件照常。恢复后 `vim.cmd("doautocmd FileType")` 可补跑被跳过的 ft 配置（`:doautocmd` 不受 ei 影响）。这是大文件"自动禁用插件 + :Unlarge 手动加载"的核心机制。
1f. **对最后一个已加载 buffer `bdelete!` 会让 nvim 重载另一个 unloaded buffer**（BufReadPre 重新触发）——headless 多窗口测试里"删除后状态异常"可能只是测错了对象，先确认当前 buffer 是谁（`nvim_get_current_buf`）再断言。
2. **`vim.lsp.util.make_position_params()` 必须传 `position_encoding`**（0.12）。如果请求只需要 `TextDocumentIdentifier`（如 `textDocument/switchSourceHeader`），直接 `{ uri = vim.uri_from_bufnr(bufnr) }`。
3. **`conceallevel` / `concealcursor` 自 0.11 起是 window-local**（options.txt 可查 "local to window"）。`nvim_set_option_value(..., { buf = })` 直接报错。且 `vim.go` 对它**读/写都不可靠**：设窗口值会污染 `vim.go` 的读取；`vim.go` 的 setter 不影响新窗口。需要"全局默认"时，在改动任何窗口值**之前**先捕获。
4. **`nvim_buf_get_keymap()` 只返回 buffer-local 键位**；全局键位用 `nvim_get_keymap()`。
5. **0.12 事件顺序：FileType 先于 BufWinEnter**（实测 BWE 触发时 filetype 已就绪）。依赖 filetype 的 autocmd 用 BufWinEnter 是安全的。
6. **window-local 选项用 `vim.o.x = v` 只影响当前窗口**，不是全局默认。
7. **`vim.bo.name` 不存在**（name 是 buffer 变量不是选项）→ `vim.api.nvim_buf_get_name(0)`。
8. **区分"请求失败"和"结果为空"**：LSP request 的 err 回调里，err 非空是传输/协议失败（ERROR + `vim.inspect(err)`），err 为空但 result 为空是业务无结果（WARN）。混在一起用户无法排查。

### 4.2 lazy.nvim
9. **本地插件用 `virtual = true`**：`{ "name", virtual = true, keys = {...}, config = function() ... end }`——不安装、不加 rtp、config 照跑（源码：types.lua + loader/meta/plugin 三处配套）。**不要用自指 `dir`**（会把非插件目录加进 rtp，插件名还会变成目录名）。
10. **`lazy = true` 且无任何触发器（keys/cmd/event/ft）= 永不加载**（除非被别的 spec 依赖）。曾因此误判"删掉 blink 的 LuaSnip 依赖边"——那其实是唯一加载路径。
11. **依赖边 = 加载顺序保证**：A 的 dependencies 里的 B 一定先于 A 的 config 加载。
12. **lazy 启动时不会把所有插件注入 `package.path`**（实测 toggleterm 启动时不在）。config/回调里 `require("某插件.module")` 前，必须确保该插件已加载——把它声明为真实 dependency，别指望"它肯定加载了"。
13. **`require("lazy").plugins` 是函数**（这个版本），调用 `require("lazy").plugins()` 拿列表。
14. **spec 校验发生在启动时**：坏 spec 启动即报错。改完 spec 先跑 `CONFIG_OK` 启动检查。
15. **删插件要删三处**：spec 文件 + `lazy-lock.json` 条目 + `~/.local/share/nvim/lazy/<name>` clone（多机器每台都要删，clone 可能几十 MB）。lock 条目 lazy 启动时会自动清，但 clone 目录不会。
16. **lazy `cond` 在启动时求值**，适合守护"数据路径可能缺失"的插件（见 §2 跨机器插件守护）。注意 `cond` 里用 `vim.fn.expand("~/..." )`，别用 os 函数猜 HOME。

### 4.3 插件选项
17. **选项名必须对照插件当前源码，不能信记忆/旧文档**。实例：`g:tex_conceal` 是旧版 vimtex 选项，当前版本源码零引用（`grep -r tex_conceal` 无结果）——基于它做的"修复"全是无效改动。当前 vimtex 的 conceal 开关是 `g:vimtex_syntax_conceal`（字典）+ `g:vimtex_syntax_conceal_disable`。
18. **注意选项的联动/副作用**：`vimtex_syntax_enabled = 0` 关掉的是**全部语法高亮**，不只是 conceal。改一个选项前先 grep 插件源码看它控制什么。
19. **全局注册的插件（noice/blink/lualine/illuminate/yanky…）无法通用"卸载"**：没有卸载 Lua 插件的 API，per-buffer 禁用得插件自己支持（vim-illuminate 只有全局 `disable_keymaps`，没有 per-buffer 开关）。大文件场景真正重的东西（LSP/treesitter/语法/ft 插件/undo/swap）全是 ft 触发或可选项，`ei=FileType` + 显式关选项已覆盖；gitsigns 还有自带的 `max_file_length`（默认 40000 行）自动跳过。别为长尾全局插件造通用开关，收益极低。

### 4.4 数据文件
20. **JSON 字符串内的裸换行 = 整个文件非法 JSON**，LuaSnip 会**静默跳过整个文件**（所有 snippet 失效，无任何报错）。多行内容必须 `\n` 转义。改完用 `vim.json.decode` 验证。
21. **JSON 重复键静默后者胜**（`vim.json.decode` 不报错）；lua 表字面量重复键同理。
22. **spell 改 `en.utf-8.add` 后要删 `en.utf-8.add.spl`**（编译缓存），否则不生效。

## 5. 工作方法论

### 5.1 动手前
- **先读实际现状，不信任记忆/摘要/上一轮的结论**。本配置改善中至少两次基于"记忆"的判断被源码推翻（P2-10 的 luasnip 加载路径、P3-14 的 tex_conceal）。
- 判断顺序：**本地 nvim 运行时文档 → 插件本地源码（lazy 目录）→ headless 实验 → 最后才 web 搜索**。headless 实验是最快的 ground truth（conceallevel 作用域混乱就是靠 3 个 10 行实验定性的）。
- 查选项作用域：`grep -A2 "'选项名'" /usr/local/share/nvim/runtime/doc/options.txt`（看 "local to window/buffer"）。
- 查插件行为：`grep -rn "选项名" ~/.local/share/nvim/lazy/<plugin>/autoload/`。
- 查 API 是否还存在：运行时文档 + headless 直接调用（报错信息本身就是文档）。

### 5.2 动手时
- **警惕静默失败**：死选项、非法 JSON、adapter 缺失但 config 仍注册、`silent!` 吞错——这类问题没有报错，只有功能悄悄没了。改完要验证"功能在"，不只是"没报错"。
- 修 bug 时区分三层：语法错（loadfile 能查）/ 加载错（启动检查能查）/ 运行时错（要打开真实文件触发）。
- 环境变量化外部依赖（host、路径），默认值保持现状：`os.getenv("NVIM_XXX") or "原值"`。

### 5.3 收尾
- **提交规范**：逻辑批次一个 commit，message 写清"改了什么 + 为什么"（参考 `git log` 里 5959587 / 769f042 的格式）。用户确认范围后再动手；用户说"先不用"的部分写进状态文件，不要顺手做。
- **状态文件**：`tmp/nvim-improvement-state.md`（gitignored）——多批次任务每完成一批就更新，包含：环境事实、已完成（含验证方式）、待办、遗留（用户明确不做的）。上下文压缩后先读它。
- **并行协作**：同一工作区同一时间只让一个 agent 写文件；并行任务用 worktree。改完 `git status` 必须干净（除 gitignored 的 tmp/）。
- 涉及用户可感知行为的改动（键位、显示、AI 连接），headless 验证通过后**明确告诉用户要试哪几个操作**。
