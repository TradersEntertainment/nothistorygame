#!/usr/bin/env bash
# Yerleşim denetimi (v0.99.101): her bölüm test botuyla oynanır, tests/layout_audit.gd oyuncunun gittiği her yerde
# çevreyi tarar ve "LAYOUT tür ..." satırları basar (havada asılı eşya, tabeladan taşan yazı, ardı duvar açık kapı,
# duvara yapışık oturan, koridor ortasında duran kişi, testere dişi gölge). SHOTS=1 ile sanal ekranda (Xvfb) koşar ve
# her bulgunun yakın planını kaydeder (doğrulama: bulgu önce karede görülür, sonra düzeltilir).
# Kullanım: GODOT=... tests/layout_run.sh [paralel=3] [bölüm...]
# Çıktı: tests/out/layout/<bölüm>.txt, özet tests/out/layout/SUMMARY.txt; kareler tests/out/layout/shots/<bölüm>/
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
PAR="${1:-3}"; shift 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(0 1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 15 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT=tests/out/layout; mkdir -p "$OUT"; : > "$OUT/SUMMARY.txt"
one() {
  local c=$1
  if [ "${SHOTS:-0}" = "1" ]; then
    mkdir -p "$OUT/shots/$c"
    LAYOUTAUDIT=1 LAYOUTSHOT="$(realpath "$OUT/shots/$c")" timeout 1800 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . \
      --resolution 1280x720 -- --chapter="$c" --autotest > "$OUT/$c.log" 2>&1
  else
    LAYOUTAUDIT=1 timeout 900 "$GODOT" --headless --max-fps 20 --path . -- --chapter="$c" --autotest > "$OUT/$c.log" 2>&1
  fi
  grep -E "^LAYOUT " "$OUT/$c.log" | grep -vE "^LAYOUT (SUNSHADOW|SHADOWLIGHT) " | awk '!seen[$0]++' > "$OUT/$c.txt"
  grep -q "AUTOTEST PASS" "$OUT/$c.log" || echo "NOPASS chapter=$c" >> "$OUT/SUMMARY.txt"
  grep -h "SCRIPT ERROR" "$OUT/$c.log" | awk '!seen[$0]++' | sed "s/^/[$c] /" >> "$OUT/SUMMARY.txt"
  sed "s/^/[$c] /" "$OUT/$c.txt" >> "$OUT/SUMMARY.txt"
}
export -f one; export GODOT OUT
printf '%s\n' "${CHAPTERS[@]}" | xargs -P "$PAR" -I{} bash -c 'one {}'
echo "Bitti -> $OUT/SUMMARY.txt ($(grep -c "LAYOUT" "$OUT/SUMMARY.txt") bulgu)"
