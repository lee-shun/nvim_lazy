# zathura-cite 设计文档

日期：2026-10-03
状态：待用户评审

## 1. 目标

在 nvim（Obsidian vault 笔记）与 zathura（PDF 阅读器）之间建立双向引用：

1. **正向**：zathura 中选中 PDF 文字按 `Y` → nvim 当前光标处插入格式化引用
2. **反向**：nvim 中光标停在引用行按 `<CR>` → zathura 跳到该 PDF 对应页

与 obsidian.nvim 共存：`<CR>` 在引用行上是 zathura 跳转，其他位置保持 obsidian.nvim 的 smart_action 原行为。

## 2. 非目标（YAGNI）

- 不做配置 UI / option 体系（路径、键位写死，后续需要再加）
- 不做 Windows/Wayland（用户机器为 i3 X11）
- 不做参考文献自动管理（只插行内引用，不维护 References 区）
- 不做 nvim 离线兜底（插入失败时选中文字已在剪贴板，用户可手粘）
- 不做 LSP 集成

## 3. 已验证的环境事实（实测结论，非假设）

- zathura 0.4.9：`zathurarc` 中 `map Y exec 脚本\ $PAGE` 把**页码（1-based）**传给外部脚本；`$FILE` 展开后被 zathura 按空格切 argv（实测），带空格路径不可用
- zathura **窗口标题 = 当前文档全路径**（含空格完整）→ 脚本经 `xdotool search --class zathura` 逐窗取 `*.pdf` 标题得文件路径
- zathura `selection-clipboard clipboard`（用户已配置）：选中文字自动进 X CLIPBOARD，脚本内 `xclip -o -selection clipboard` 可靠读出
- 本机 nvim 构建（/home/ls/neovim_source, Zig）的 pattern 引擎在 pattern 含 `-` 时行为错误：`string.find` 模式模式返回错误位置，`string.match` 混合元字符时直接 nil（实测）→ 插件所有含 `-` 的匹配一律用 plain find / sub 前缀判断
- `install_zathurarc` 维护语义：剔除所有 zath-cite map 行后追加当前行；当前行存在且无其他旧行才 no-op
- `plugin_dir` 必须经 `vim.uv.fs_realpath` 归一化：`vim.fs.abspath` 不解析 symlink，plugin 经 site symlink 加载与直接加载会得到不同路径 → zathurarc map 行来回翻转（实测）
- zathura 窗口标题包含文件名 basename（`xdotool search --name <basename>` 可定位窗口）
- obsidian.nvim 在 vault 的 markdown buffer 设置 buffer-local `n <CR>` = `actions.smart_action`（expr mapping）；光标在链接上会执行 `:Obsidian follow_link`
- obsidian.nvim 在 setup 后触发用户 autocmd `ObsidianNoteEnter`（晚于其 keymap 注册，可用于覆盖挂载点）
- xclip / xdotool 已安装

## 4. 组件与文件落点

```
~/.local/share/nvim/site/zathura-cite/
├── plugin/zathura_cite.lua     # 插件主体（Lua，启动即载，无依赖）
└── bin/zath-cite.sh            # zathura 端中转脚本（~15 行 sh）
```

- `~/.config/zathura/zathurarc` 追加一行（插件启动时自动检测/补写，重复不写）：
  ```
  map Y exec /home/ls/.local/share/nvim/site/zathura-cite/bin/zath-cite.sh\ $PAGE
  ```
- nvim 只扫描 `<rtp>/plugin/` 一层：`~/.local/share/nvim/site/plugin/zathura_cite.lua` 是 shim（symlink 到仓库 `loader.lua`），加载嵌套项目。
- 前提：有 nvim 实例监听 `$NVIM_LISTEN_ADDRESS`（默认 `/tmp/nvimsocket`）——用户主实例经 nvr 启动即满足（synctex 已在用）

## 5. 数据通道（无中间文件）

zathura Y → `bin/zath-cite.sh`：
1. 页码 ← `$1`；PDF 全路径 ← zathura 窗口标题（`xdotool` 逐窗取 `*.pdf`）
2. 选中文字 ← `xclip -o -selection clipboard`，压平成单行（换行/制表符→空格，去首尾空白）
3. sh 拼引用串（`build_citation`，可 source 单测）
4. 引用串 → `xclip -selection clipboard` → `nvim --server $server --remote-expr 'execute("normal! \"\\\"+p")'` 在光标字符后粘贴

文本全程只走 X 剪贴板，不进 shell 参数或 Lua 字符串 → **零转义**。

## 6. 正向：插入行为

- 插入位置：光标字符**之后**（`normal! \"+p` 粘贴 @+）；行尾则接在行尾
- 当前 buffer 是哪一个就插哪一个（nvim 前台焦点 buffer）；不校验 vault——选中文本属于哪个笔记由用户焦点决定
- 空选区 → 脚本静默退出（不覆盖剪贴板、不插入）
- 无 nvim 实例 / 未监听 → `--remote-expr` 失败，脚本静默退出（选中文字仍在剪贴板）

命令接口（测试/手动用）：
- `:ZathuraCiteJump` — 对光标行执行反向跳转（见 §7）
## 7. 反向：跳转行为

`<CR>` dispatcher（buffer-local，n 模式，expr mapping）：

1. 光标行匹配引用模式：行内含指向 PDF 的 wikilink 或 markdown link，**且**行内有 `p.<N>`
   - wikilink 目标解析：`[[rel/path]]` → vault 根 + rel/path.pdf（需确认文件存在；basename 存在但路径不同则按 basename 在 vault 内 find 一次）；`[[rel/path.pdf]]` → 直接用
   - 解析失败 → 回退 obsidian 行为（不报错打断）
2. 找到 PDF 和页码 N：
   - `xdotool search --name <basename>` 有窗口 → 激活窗口 + `xdotool key --window W <N> G`
   - 无窗口 → `zathura -P N <file>` 后台开新窗
3. 行不匹配引用模式 → 原样调用 `require("obsidian.actions").smart_action()`（expr 返回其结果）；obsidian.nvim 不存在时返回 `"<CR>"`

挂载点：
- 主路径：hook `ObsidianNoteEnter` 用户 autocmd（保证晚于 obsidian 的 keymap 注册，直接覆盖）
- 兜底：若该 autocmd 从未触发（obsidian.nvim 未启用），插件自己的 FileType markdown + 文件在 vault 判定后挂同一 mapping
- 判定"引用行"的 regex 与 §6 插入格式严格对应，保证自己插的引用 100% 可跳转

## 8. 错误处理

| 场景 | 行为 |
|---|---|
| zathura 未开窗口（反向） | 自动 `zathura -P N file` |
| 空选区（正向） | 脚本静默退出（不动剪贴板） |
| xclip 读不到（无 CLIPBOARD） | text 为空，同上 |
| obsidian.nvim require 失败 | dispatcher 退化为纯 zathura 判定 + `<CR>` |
| zathurarc 已含本 map 行 | 不重复写 |
| 无 nvim 实例监听（正向） | `--remote-expr` 失败，脚本静默退出（文字仍在剪贴板） |
| alpha 启动页为焦点（正向） | 粘贴落到 readonly 启动页被拒（W10）；用户切到笔记窗口即可，不做处理 |

## 9. 测试计划

1. **脚本单测**：source `bin/zath-cite.sh`（main guard 阻止执行）→ `build_citation` 各分支断言（vault 内/外、深目录、含特殊字符文本、vault 不存在）
2. **core 单测**：`match_citation_line` 各分支（wikilink 相对/绝对/.pdf 后缀/md 链接/幽灵链接/多位页码/p.N 无链接）+ `install_zathurarc`（幂等/旧行替换/无尾换行）
3. **remote 机制单测**：后台 `nvim --listen` → `--remote-expr setline/cursor/execute(normal! "+p)` → 断言行内容（含刁钻文本零转义往返）
4. **正向 e2e**：真开 zathura → 鼠标选中 → Y → 前台 nvim 光标字符后出现正确引用
5. **反向 e2e**：光标在引用行 `<CR>` → zathura 跳页（截图 RMSE 对比断言页面变化）
6. **共存回归**：光标在普通 wikilink 上 `<CR>` → 仍走 obsidian follow_link；空行 → toggle_checkbox；非 vault buffer 无 keymap

## 10. 关键决策记录

- 数据通道选 **exec + 剪贴板 + 窗口标题 + nvim --remote-expr** 而非 D-Bus 或 drop 文件：D-Bus 服务名在本机 tmux 环境未观察到注册；remote-expr 实测可用（nvim ≥0.10 需显式 --server），文本走 X 剪贴板实现**零转义**（含引号/$/反引号/反斜杠/CJK 原样往返）
- 正向不再有中间 drop 文件：脚本拼好引用串后直接 `nvim --server $NVIM_LISTEN_ADDRESS --remote-expr 'execute("normal! \"\\\"+p")'` 粘贴 @+；无 nvim 实例时插入失败，但选中文字已在剪贴板（用户可手粘），不做文件兜底
- **$FILE 不可经 exec 传参**（zathura 展开后按空格切 argv，实测），改从窗口标题取全路径
- 插件需 shim 加载：nvim 不扫描嵌套 plugin/ 目录（实测），`site/plugin/zathura_cite.lua` shim -> 项目 loader
- 反向键用 `<CR>` 覆盖而非另加键：用户明确要求 Enter；覆盖时保留 obsidian 原逻辑
- 插件放 `~/.local/share/nvim/site/zathura-cite/` 独立自包含（脚本在内）：不进 lazy（无依赖、启动即载、~150 行无成本），多机同步后续再升级为 repo
