#!/bin/bash
# sahne.sh <cikti> <sahne.tscn> [kullanıcı argümanları...] — ekransız sahne koşusu (--max-fps 20)
out="$1"; sc="$2"; shift 2
cd "${PROJ:-/home/user/nothistorygame}"
timeout 600 ~/is/godot/godot --headless --max-fps 20 --path . "$sc" -- "$@" > "$out.ham" 2>&1
echo "KOSU rc=$? args=$sc $*" >> "$out.ham"
grep -E 'SURSOZLESME|SUROYUN|WALKTHRU|SCRIPT ERROR|Parse Error|KUMAS|KOSU' "$out.ham" | cut -c1-400 > "$out"
