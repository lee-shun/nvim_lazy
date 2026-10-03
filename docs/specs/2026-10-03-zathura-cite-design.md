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
- 不做多 drop 文件并发处理（只取最新一个）
- 不做 LSP 集成

## 3. 已验证的环境事实（实测结论，非假设）

- zathura 0.4.9：`zathurarc` 中 `map Y exec 脚本\ $PAGE` 把**页码（1-based）**传给外部脚本；`$FILE` 展开后被 zathura 按空格切 argv（实测），带空格路径不可用
- zathura **窗口标题 = 当前文档全路径**（含空格完整）→ 脚本经 `xdotool search --class zathura` 逐窗取 `*.pdf` 标题得文件路径
- zathura `selection-clipboard clipboard`（用户已配置）：选中文字自动进 X CLIPBOARD，脚本内 `xclip -o -selection clipboard` 可靠读出
- 本机 nvim 构建（/home/ls/neovim_source, Zig）的 pattern 引擎在 pattern 含 `-` 时行为错误：`string.find` 模式模式返回错误位置，`string.match` 混合元字符时直接 nil（实测）→ 插件所有含 `-` 的匹配一律用 plain find / sub 前缀判断
- `install_zathurarc` 维护语义：移除**所有** zath-cite map 行后追加当前行（处理 script 路径变化，如 symlink 解析导致 plugin_dir 变化；当前行存在且无旧行才 no-op）
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
- `/tmp/zathura-cite/`：drop 目录（运行时产物，不入 git）

## 5. 数据格式

`bin/zath-cite.sh` 收到 `page` 参数后，从 zathura 窗口标题取 file，写 `/tmp/zathura-cite/<YYYYmmddHHMMSS_NANOS>.txt`：

```
<page>            # 1-based 页码
<file>            # PDF 绝对路径
<selected text>   # 第 3 行起，可多行；无选区时为空
```

- 文件名含纳秒时间戳保证并发唯一
- 脚本不依赖 nvim 在线；nvim 离线时文件留在目录里，下次启动消费（或手动 `:ZathuraCiteLatest`）

## 6. 正向：插入行为

nvim 插件 500ms uv timer 轮询 drop 目录。触发条件（全部满足才消费）：
- 当前 buffer 是 markdown 且文件位于 vault（`~/knowledge_library`）内
- 目录里有未消费文件

消费流程：
1. 取最新文件，读取 page/file/text，**立即删除**该文件（防重复消费）
2. text 为空 → 提示 "zathura-cite: 无选中文字"，结束
3. 清理 text：换行/制表符压成单空格，去首尾空白
4. 生成引用（插入在光标处）：
   - PDF 在 vault 内：`[[<vault 相对路径，去 .pdf 后缀>|<basename>]] p.<page>: "<text>"`
     例：`[[literature/2017_msckf_notes|2017_msckf_notes]] p.3: "MSCKF is a filter-based VIO..."`
   - PDF 不在 vault 内：`[<basename>](<绝对路径>) p.<page>: "<text>"`
5. 提示插入完成（echo 一行即可）

命令接口（测试/手动用）：
- `:ZathuraCiteLatest` — 手动消费 drop 目录最新文件并插入
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
| 空选区（正向） | 提示后丢弃 drop 文件 |
| xclip 读不到（无 CLIPBOARD） | text 为空，同上 |
| obsidian.nvim require 失败 | dispatcher 退化为纯 zathura 判定 + `<CR>` |
| zathurarc 已含本 map 行 | 不重复写 |
| drop 目录不存在 | 创建 |
| timer 轮询开销 | 仅在 markdown+vault buffer 且目录非空时做重活，其余路径 O(1) |

## 9. 测试计划

1. **脚本单测**：手动 `sh bin/zath-cite.sh 3 /path/x.pdf` + 预先 `xclip -loop -i` 放文本 → 校验 drop 文件三行格式
2. **插入单测**：造假 drop 文件 → `:ZathuraCiteLatest` → 断言插入文本格式、文件被删、空文本被拦截
3. **正向 e2e**：真开 zathura → 选中 → Y → nvim 光标处出现正确引用
4. **反向 e2e**：光标在引用行 `<CR>` → zathura 跳页（已开/未开两种情况）
5. **共存回归**：光标在普通 wikilink 上 `<CR>` → 仍走 obsidian follow_link；无链接行 `<CR>` → 正常 CR

## 10. 关键决策记录

- 数据通道选 **exec + 剪贴板 + 窗口标题** 而非 D-Bus：D-Bus 服务名在本机 tmux 环境未观察到注册（疑似会话总线差异），而 exec+剪贴板+标题已实测可用、版本无关
- **$FILE 不可经 exec 传参**（zathura 展开后按空格切 argv，实测），改从窗口标题取全路径
- 插件需 shim 加载：nvim 不扫描嵌套 plugin/ 目录（实测），`site/plugin/zathura_cite.lua` shim -> 项目 loader
- 反向键用 `<CR>` 覆盖而非另加键：用户明确要求 Enter；覆盖时保留 obsidian 原逻辑
- 插件放 `~/.local/share/nvim/site/zathura-cite/` 独立自包含（脚本在内）：不进 lazy（无依赖、启动即载、~150 行无成本），多机同步后续再升级为 repo
