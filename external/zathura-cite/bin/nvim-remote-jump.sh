#!/bin/sh
# synctex-editor-command 用：$1=tex 文件 $2=行号
# zathura Ctrl+点击 -> nvim 对应行。
# 多实例：优先选已加载该文件的活实例，否则取最新活实例。
file="$1"; line="$2"
[ -n "$file" ] && [ -n "$line" ] || exit 1

# 活 socket 列表（env -> 固定名 -> /tmp/nvim* 按 mtime 降序，去重）
servers=""
for cand in ${NVIM_LISTEN_ADDRESS:-} /tmp/nvimsocket $(ls -t /tmp/nvim* 2>/dev/null); do
  [ -n "$cand" ] && [ -S "$cand" ] || continue
  case "$servers" in *" $cand "*) continue ;; esac
  nvim --server "$cand" --remote-expr '1' >/dev/null 2>&1 || continue
  servers="$servers $cand"
done
[ -n "$servers" ] || exit 1

# vimscript 字符串转义
vfile=$(python3 - "$file" <<'PY'
import sys
print(sys.argv[1].replace("\\", "\\\\").replace("'", "\\\\'"))
PY
)
server=""
for s in $servers; do
  # 已加载该文件的实例优先
  if nvim --server "$s" --remote-expr "bufnr('$vfile') >= 0" 2>/dev/null | grep -q '^1'; then
    server="$s"; break
  fi
done
[ -n "$server" ] || server=$(echo $servers | awk '{print $NF}')

nvim --server "$server" --remote-silent "$file" >/dev/null 2>&1
nvim --server "$server" --remote-expr "cursor([$line,1])" >/dev/null 2>&1
