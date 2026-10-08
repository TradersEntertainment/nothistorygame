#!/bin/bash
# EXITCHECK: dünyayı kullanan her bölümde oyun alanının dışına yürünebiliyor mu (ikişer paralel).
#   GODOT=... bash tests/exit_all.sh [bölüm ...]
GODOT=${GODOT:-godot}
CHS=${@:-"0 6 7 9 10 10b 10g 10h 10z 11 12b 13 16 17 17o 18 18b 19 19o 20 20o 21 22 22o 23 24 24o 25 26 26o 27 28o 29 29o 30 30o 36b 31o 32o 37o 38o 39o"}
fail=0
out=$(printf "%s\n" $CHS | xargs -P ${PAR:-2} -I{} sh -c "timeout 500 \"$GODOT\" --headless --path . -- --chapter={} --exitcheck 2>&1 | grep -E 'EXITCHECK chapter|SCRIPT ERROR' | head -2 || echo 'EXITCHECK chapter={} TIMEOUT FAIL'")
echo "$out" | sort
echo "$out" | grep -q "FAIL\|SCRIPT ERROR" && fail=1
echo "EXITALL $([ $fail = 0 ] && echo PASS || echo FAIL)"
exit $fail
