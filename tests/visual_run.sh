#!/usr/bin/env bash
# Görüntülü denetim (v0.99.68): her bölüm sanal ekranda (Xvfb) test botuyla oynanır; her replik ekrandayken bir kare
# (ANAHTAR.jpg) ve her 4 sn'de bir oynanış karesi (tNNNN.jpg) alınır. tools/frame_check.py kareleri sayıyla denetler
# (kapkara/bembeyaz, düz renk, donmuş görüntü) ve 2x2 pafta yapar: paftalar göz denetimi için (insan ya da görsel ajan).
# Kullanım: GODOT=... tests/visual_run.sh [paralel=2] [bölüm...]   (xvfb-run gerekir)
# Çıktı: tests/out/visual/<bölüm>/ kareler, _log.txt, sheets/; özet tests/out/visual/SUMMARY.txt
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
PAR="${1:-2}"; shift 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(0 1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 15 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT=tests/out/visual; mkdir -p "$OUT"; : > "$OUT/SUMMARY.txt"
one() {
  local c=$1 dir="$OUT/$1"
  rm -rf "$dir"; mkdir -p "$dir"
  timeout 1800 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --resolution 1280x720 -- \
    --chapter="$c" --autotest --dialogshots="$(realpath "$dir")" --shotevery=1 --snapevery=4 > "$dir/_log.txt" 2>&1
  local rc=$?
  { [ $rc -eq 124 ] && echo "TIMEOUT chapter=$c"
    grep -q "AUTOTEST PASS" "$dir/_log.txt" || echo "NOPASS chapter=$c"
    grep -hE "^(VISAUDIT|HELDAUDIT|ARMAUDIT|WALKTHRU) |SCRIPT ERROR|WARN_" "$dir/_log.txt" | grep -v "^WARNING" | awk '!seen[$0]++' | sed "s/^/[$c] /"
    python3 tools/frame_check.py "$dir" | sed "s/^/[$c] /"; } >> "$OUT/SUMMARY.txt"
}
export -f one; export GODOT OUT
printf '%s\n' "${CHAPTERS[@]}" | xargs -P "$PAR" -I{} bash -c 'one {}'
echo "Bitti -> $OUT/SUMMARY.txt ($(grep -c . "$OUT/SUMMARY.txt") satır)"
