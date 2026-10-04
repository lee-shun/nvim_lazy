#!/bin/sh
# zathura exec 回调：$1=页码(1-based)
# 流程：窗口标题取 PDF 路径 -> X CLIPBOARD 取选中文字 -> sh 拼引用串
#       -> 引用串入 CLIPBOARD -> nvim --remote-expr 在光标处粘贴（零转义：文本不走 shell/Lua 字符串）
# 前提：有 nvim 实例监听 $NVIM_LISTEN_ADDRESS（默认 /tmp/nvimsocket）

build_citation() {
  # $1=page $2=pdf 全路径 $3=文本 $4=vault 根
  # Obsidian 原生「引用+链接」格式（zathura 拿不到 selection 坐标，略去）：
  #   > 文本
  #   [[rel.pdf#page=N|base, p.N]]   vault 内 PDF（Obsidian 点开直达该页）
  #   [base](abs.pdf)                vault 外 PDF
  page="$1"; file="$2"; text="$3"; vault="$4"
  base=${file##*/}
  base=${base%.pdf}
  prefix="$vault/"
  case "$file" in
    "$prefix"*)
      rel=${file#"$prefix"}
      case "$rel" in
        *.pdf) printf '> %s\n[[%s#page=%s|%s, p.%s]]' "$text" "$rel" "$page" "$base" "$page" ;;
        *)     printf '> %s\n[%s](%s)' "$text" "$base" "$file" ;;
      esac
      ;;
    *)
      printf '> %s\n[%s](%s)' "$text" "$base" "$file" ;;
  esac
}

main() {
[ -n "${1:-}" ] || exit 1
page="$1"

# PDF 全路径：zathura 窗口标题（含空格安全）
file=""
for _w in $(xdotool search --class zathura 2>/dev/null); do
  _n=$(xdotool getwindowname "$_w" 2>/dev/null)
  case "$_n" in *.pdf) file="$_n"; break ;; esac
done
[ -n "$file" ] || exit 1

# 选中文字：X CLIPBOARD，压平成单行
text=$(xclip -o -selection clipboard 2>/dev/null | tr '\r\n\t' '   ' | sed 's/^ *//; s/ *$//')
[ -n "$text" ] || exit 0

cite=$(build_citation "$page" "$file" "$text" "$HOME/knowledge_library")

# 零转义通道：引用串 -> CLIPBOARD -> nvim 粘贴 @+
printf '%s' "$cite" | xclip -selection clipboard
# 探测活 socket：$NVIM_LISTEN_ADDRESS 优先，其次固定名，其余 nvim* 按 mtime 新→旧
# ponytail: 多活实例并存时挑最近用过的，极端情况可挑错；要确定性就只开一个带 socket 的 nvim
server=""
for cand in ${NVIM_LISTEN_ADDRESS:-} /tmp/nvimsocket $(ls -t /tmp/nvim* 2>/dev/null); do
  [ -n "$cand" ] && [ -S "$cand" ] || continue
  if nvim --server "$cand" --remote-expr '1' >/dev/null 2>&1; then
    server="$cand"; break
  fi
done
nvim --server "$server" --remote-expr 'execute("normal! \"+p")' 2>/dev/null

}

# 直接执行才跑 main；被 source 时只导出 build_citation（测试用）
if [ "$(basename "$0")" = "zath-cite.sh" ]; then
  main "$@"
fi
