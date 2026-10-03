#!/bin/sh
# zathura exec 回调：$1=页码(1-based)
# PDF 路径取自 zathura 窗口标题（全路径，空格安全）；选中文本取自 X CLIPBOARD
page="$1"
file=""
for _w in $(xdotool search --class zathura 2>/dev/null); do
  _n="$(xdotool getwindowname "$_w" 2>/dev/null)"
  case "$_n" in *.pdf) file="$_n"; break ;; esac
done
dir="/tmp/zathura-cite"
mkdir -p "$dir"
ts="$(date +%Y%m%d%H%M%S_%N)"
text="$(xclip -o -selection clipboard 2>/dev/null)"
{ printf '%s\n%s\n%s\n' "$page" "$file" "$text"; } > "$dir/$ts.txt"
