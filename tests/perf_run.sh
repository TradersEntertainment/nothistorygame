#!/usr/bin/env bash
# Çizim bütçesi ölçümü (v0.99.108): her bölüm sanal ekranda test botuyla oynanır, takılma denetçisi iki saniyede bir
# çizim çağrısı ve üçgen sayısını (ana görüntü ve gölge geçişi ayrı) yazar (RINFO). tools/perf_report.py bunlardan
# docs/PERF.md tablosunu kurar: sahne başına ortanca ve en yüksek değer, bütçeyi (6.000 çizim, 5 M üçgen) aşanlar.
# Sayılar ekran kartından bağımsızdır (kaç nesne, kaç üçgen çizildiği); kare süresi yazılımla çizimde anlamsızdır.
# Kullanım: GODOT=... tests/perf_run.sh [paralel=2] [bölüm...]   (xvfb-run gerekir)
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
PAR="${1:-2}"; shift 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(0 1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 15 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT=tests/out/perf; mkdir -p "$OUT"
one() {
  local c=$1
  RINFO=1 timeout 1500 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --resolution 1280x720 --max-fps 60 -- \
    --chapter="$c" --autotest --hitchaudit 2>&1 | grep -E "^RINFO|AUTOTEST PASS" > "$OUT/$c.txt"
  echo "bitti $c: $(grep -c '^RINFO' "$OUT/$c.txt") ölçüm"
}
export -f one; export GODOT OUT
printf '%s\n' "${CHAPTERS[@]}" | xargs -P "$PAR" -I{} bash -c 'one {}'
python3 tools/perf_report.py "$OUT"
