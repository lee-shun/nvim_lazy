#!/bin/bash
# build_citation 单元测（source 脚本，guard 阻止 main 执行）
SCRIPT=~/.config/nvim/external/zathura-cite/bin/zath-cite.sh
. "$SCRIPT"
pass=0; fail=0
check() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: expected [$2] got [$1]"; fi; }
V=/home/ls/knowledge_library
check "$(build_citation 3 "$V/literature/2017_msckf_notes.pdf" "hello" "$V")" '[[literature/2017_msckf_notes|2017_msckf_notes]] p.3: "hello"'
check "$(build_citation 1 "$V/note/Visual_SLAM14/ch5_Camera/camera.pdf" "t" "$V")" '[[note/Visual_SLAM14/ch5_Camera/camera|camera]] p.1: "t"'
check "$(build_citation 7 "/tmp/x.pdf" "t" "$V")" '[x](/tmp/x.pdf) p.7: "t"'
check "$(build_citation 2 "/a/b/2017_msckf_notes.pdf" "q" "$V")" '[2017_msckf_notes](/a/b/2017_msckf_notes.pdf) p.2: "q"'
check "$(build_citation 12 "/a b/x.pdf" 'we"ird $txt \back' "$V")" '[x](/a b/x.pdf) p.12: "we"ird $txt \back"'
check "$(build_citation 1 "$V/x.pdf" "t" "$V")" '[[x|x]] p.1: "t"'
# 无 vault（不存在）-> 全部 markdown
check "$(build_citation 1 "$V/literature/2017_msckf_notes.pdf" "t" /tmp/no_such_vault_zc)" "[2017_msckf_notes]($V/literature/2017_msckf_notes.pdf) p.1: \"t\""
echo "script: $pass passed, $fail failed"
[ $fail -eq 0 ]
