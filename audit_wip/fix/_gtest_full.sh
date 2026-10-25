#!/usr/bin/env bash
# Kullanım: gtest.sh PARSE            -> betik ayrıştırma denetimi
#           gtest.sh --chapter=20 --autotest[=varyant] [--flag=...]  -> bir bölümü otomatik oynatır
# En fazla 3 Godot aynı anda çalışır (sıra bekler). Çıktı: önemli satırlar (PASS/FAIL/SCRIPT ERROR/VISAUDIT...).
S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad
A=$S/audit; G=$S/godot/godot; cd /home/user/nothistorygame
slot=""
while [ -z "$slot" ]; do
  for i in 1 2 3; do
    exec {fd}>"$A/locks/g$i"
    if flock -n $fd; then slot=$i; break; fi
    exec {fd}>&-
  done
  [ -z "$slot" ] && sleep 3
done
if [ "$1" = "PARSE" ]; then
  timeout 180 $G --headless --path . res://tests/parse_check.tscn 2>&1 | grep -E "PARSECHECK|Parse Error|Compile Error|ERROR" | head -40
  exit 0
fi
out=$(timeout 420 $G --headless --max-fps 20 --path . -- "$@" 2>&1); rc=$?
[ $rc -eq 124 ] && echo "AUTOTEST TIMEOUT $*"
echo "$out" > /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/_f03_full_y.txt; echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_VOID|FAIL|ERROR|at: res|res://.*:[0-9]" | grep -vE "^WARNING|resources still in use|environment_set_ss|RID allocations|ObjectDB instances" | head -60
