#!/usr/bin/env bash
# Ses denetimi (v0.99.68): her bölüm test botuyla replikleri gerçek süresinde çalarak oynanır (PACE); başsız sürücü sesi
# yine de karıştırır, AudioAudit (scripts/autoload/audio_audit.gd) yolları ölçer. Bulgular: yarıda kesilen, duyulmayan,
# üst üste binen replik; kırpılan yol; konuşmayı örten müzik; müzik boşluğu. Bölümler arası düzey: tools/audio_report.py
# Kullanım: GODOT=... tests/audio_run.sh [paralel=3] [bölüm...]
# Çıktı: tests/out/audio/<bölüm>.log, levels.csv ve özet SUMMARY.txt (bölüm başına birkaç dakika: gerçek süre)
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
PAR="${1:-3}"; shift 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(0 1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 15 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT=tests/out/audio; mkdir -p "$OUT"; rm -f "$OUT/levels.csv"; : > "$OUT/SUMMARY.txt"
one() {
  local c=$1 log="$OUT/$1.log"
  timeout 1800 "$GODOT" --headless --max-fps 20 --path . -- --chapter="$c" --autotest --audioaudit="$OUT" > "$log" 2>&1
  local rc=$?
  { [ $rc -eq 124 ] && echo "TIMEOUT chapter=$c"
    grep -q "AUTOTEST PASS" "$log" || echo "NOPASS chapter=$c"
    grep -h "^AUDIOAUDIT " "$log" | sed "s/^/[$c] /"; } >> "$OUT/SUMMARY.txt"
}
export -f one; export GODOT OUT
printf '%s\n' "${CHAPTERS[@]}" | xargs -P "$PAR" -I{} bash -c 'one {}'
echo "Bulgu: $(grep -c "AUDIOAUDIT\|NOPASS\|TIMEOUT" "$OUT/SUMMARY.txt") satır -> $OUT/SUMMARY.txt"
