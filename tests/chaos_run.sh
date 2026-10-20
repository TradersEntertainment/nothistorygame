#!/usr/bin/env bash
# Kaos koşusu (v0.99.22): her bölümü kendi test botuyla oynatırken kaos botu (scripts/autoload/chaos.gd) araya yaramaz
# girdiler sokar. Bölüm bitmezse (AUTOTEST PASS yok) ya da bir denetim tetiklenirse bulgu; yeniden üretmek için
# aynı satırı (--chapter=X --autotest --chaos=TOHUM) koşmak yeter.
# Kullanım: GODOT=... tests/chaos_run.sh [tohum sayısı=2] [paralel=3] [bölüm...]
# Çıktı: tests/out/chaos/<bölüm>_<tohum>.log ve özet tests/out/chaos/SUMMARY.txt
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
SEEDS="${1:-2}"; PAR="${2:-3}"; shift 2 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(0 1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT=tests/out/chaos; mkdir -p "$OUT"; : > "$OUT/SUMMARY.txt"
one() {
  local c=$1 s=$2 log="$OUT/${1}_${2}.log"
  timeout 420 "$GODOT" --headless --max-fps 20 --path . -- --chapter="$c" --autotest --chaos="$s" > "$log" 2>&1
  local rc=$? bad=""
  [ $rc -eq 124 ] && bad="TIMEOUT"
  # Kaosun yol açtığı başka bir sonuç (ör. kamera döndü, talim kaybedildi: 41O.2) hata değil, bilgi: bölüm bitti mi ona bakılır
  local alt=""
  if ! grep -q "AUTOTEST PASS" "$log"; then
    if grep -q "^AUTOTEST: beklenen" "$log"; then alt=$(grep -m1 "^AUTOTEST: beklenen" "$log" | cut -c1-80); else bad="$bad NOPASS"; fi
  fi
  # "hidden" (konuşan görünmüyor) oyuncunun nerede durduğuna bağlı: kaos oyuncuyu duvar arkasına koşturabilir, sayılmaz
  local hits; hits=$(grep -E "^(VISAUDIT|HELDAUDIT|ARMAUDIT|WALKTHRU) |SCRIPT ERROR|WARN_VOID_TELEPORT|WARN_FX_STUCK" "$log" | grep -v "^VISAUDIT hidden " | awk '!seen[$0]++' | head -5)
  [ -n "$hits" ] && bad="$bad AUDIT"
  if [ -n "$bad" ]; then
    { echo "BULGU chapter=$c seed=$s:$bad"; echo "$hits" | sed 's/^/    /'; grep "^CHAOS" "$log" | tail -4 | sed 's/^/    son: /'; } >> "$OUT/SUMMARY.txt"
  else
    echo "TEMIZ chapter=$c seed=$s${alt:+ (başka sonuç: $alt)}" >> "$OUT/SUMMARY.txt"
  fi
}
for c in "${CHAPTERS[@]}"; do
  for s in $(seq "${SEED0:-1}" $(( ${SEED0:-1} + SEEDS - 1 ))); do
    one "$c" "$s" &
    while [ "$(jobs -r | wc -l)" -ge "$PAR" ]; do wait -n; done
  done
done
wait
echo "kaos: $(grep -c '^TEMIZ' "$OUT/SUMMARY.txt") temiz, $(grep -c '^BULGU' "$OUT/SUMMARY.txt") bulgu"
grep -A6 "^BULGU" "$OUT/SUMMARY.txt"
