#!/usr/bin/env bash
# Fizik-3 koşusu: fizik3_kos.sh <çıktı klasörü> <etiket> <bölüm[:çeşit]>... (EK="--eskisur …" ek argümanlar)
# Her bölüm --max-fps 20 ile ekransız, en çok 9 dk; en çok 4 süreç aynı anda. Çıktı: <klasör>/<etiket>_<bölüm>[_<n>].log
# Aynı bölüm birden çok verilirse (37o 37o 37o) sıra numarası eklenir.
set -u
GODOT="${GODOT:-$HOME/is/godot/godot}"
cd "$(dirname "$0")/../.."
out="$1"; tag="$2"; shift 2
mkdir -p "$out"
declare -A seen
jobs=()
for c in "$@"; do
  k="${c/:/_}"
  n=${seen[$k]:-0}; seen[$k]=$((n + 1))
  [ "$n" -gt 0 ] && k="${k}_$n"
  jobs+=("$c|$k")
done
printf '%s\n' "${jobs[@]}" | xargs -P 4 -I{} sh -c '
  j="{}"; c="${j%%|*}"; k="${j##*|}"
  ch="${c%%:*}"; v=""; [ "$c" != "$ch" ] && v="=${c#*:}"
  timeout 540 "'"$GODOT"'" --headless --max-fps 20 --path . -- --chapter="$ch" --autotest"$v" '"${EK:-}"' > "'"$out"'/'"$tag"'_$k.log" 2>&1
'
