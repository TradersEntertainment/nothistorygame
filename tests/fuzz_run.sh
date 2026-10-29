#!/usr/bin/env bash
# Durum + kaos koşusu (v0.99.68): her bölüm rastgele bir geçmişle (tools/state_fuzz.py: çanta, bayraklar, önceki
# sonuçlar) başlatılır ve kaos botu (--chaos) araya yaramazlık sokar. Bulgu yeniden üretmek için SUMMARY'deki satırın
# argümanlarıyla aynı komut yeter. Kaosun açtığı başka bir sonuç ("AUTOTEST: beklenen ...") hata değil, bilgi.
# Kullanım: GODOT=... tests/fuzz_run.sh [tohum sayısı=2] [paralel=3] [bölüm...]
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
SEEDS="${1:-2}"; PAR="${2:-3}"; shift 2 2>/dev/null
CHAPTERS=("$@")
if [ ${#CHAPTERS[@]} -eq 0 ]; then
  CHAPTERS=(1 2 3 4 5 6 7 8 9 10 10a 10b 10g 10h 10l 10z 11 12 12b 13 14 15 16 17 17o 18 18b 19 19o 20 20o 21 21o 22 22o
            23 24 24o 25 26 26o 27 28o 29 29o 30 30o 31o 32o 33o 34o 35o 36b 37o 38o 39o 41o 42b 43o)
fi
OUT=tests/out/fuzz; mkdir -p "$OUT"; : > "$OUT/SUMMARY.txt"
one() {
  local c=$1 s=$2 log="$OUT/${1}_${2}.log"
  local st; st=$(python3 tools/state_fuzz.py "$c" "$s")
  # shellcheck disable=SC2086
  timeout 420 "$GODOT" --headless --max-fps 20 --path . -- --chapter="$c" --autotest --chaos="$s" $st > "$log" 2>&1
  local rc=$? bad=""
  [ $rc -eq 124 ] && bad="TIMEOUT"
  if ! grep -q "AUTOTEST PASS" "$log"; then
    grep -q "^AUTOTEST: beklenen" "$log" || bad="$bad NOPASS"
  fi
  local hits; hits=$(grep -E "^(VISAUDIT|HELDAUDIT|ARMAUDIT|WALKTHRU) |SCRIPT ERROR|WARN_VOID_TELEPORT|WARN_FX_STUCK|WARN_FLY_ITEM|^JOURNEY_" "$log" | grep -v "^VISAUDIT hidden " | awk '!seen[$0]++' | head -6)
  [ -n "$hits" ] && bad="$bad AUDIT"
  if [ -n "$bad" ]; then
    { echo "BULGU --chapter=$c --autotest --chaos=$s $st:$bad"; echo "$hits" | sed 's/^/    /'
      grep -E "^CHAOS|SCRIPT ERROR|at: " "$log" | tail -5 | sed 's/^/    son: /'; } >> "$OUT/SUMMARY.txt"
  fi
}
export -f one; export GODOT OUT
for c in "${CHAPTERS[@]}"; do for s in $(seq 1 "$SEEDS"); do echo "$c $s"; done; done | xargs -P "$PAR" -n 2 bash -c 'one "$0" "$1"'
echo "Bulgu: $(grep -c '^BULGU' "$OUT/SUMMARY.txt") -> $OUT/SUMMARY.txt"
