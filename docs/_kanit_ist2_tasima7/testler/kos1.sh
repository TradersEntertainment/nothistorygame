#!/bin/bash
# kos1.sh <cikti_dosyasi> <godot argümanları...>  (taşıma 4/5'in kos1.sh'i + TASIMA6|TASIMA7 satırları)
out="$1"; shift
s=$(date +%s)
cd "${PROJ:-/home/user/nothistorygame}"
timeout 600 ~/is/godot/godot --headless --max-fps 20 --path . -- "$@" > "$out.ham" 2>&1
echo "KOSU rc=$? sure=$(( $(date +%s) - s )) args=$*" >> "$out.ham"
grep -E 'AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID|KOSU|WAVERUNNER|GUN|gunner|CESET4|TASIMA6|TASIMA7' "$out.ham" | cut -c1-600 > "$out"
