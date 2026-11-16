#!/usr/bin/env bash
# Fizik-ayak ÖNCE|SONRA koşusu: ayak_kos.sh <çıktı klasörü> <kip: once|sonra> <bölüm[:çeşit]>...
# Her bölüm --max-fps 20 ile ekransız, en çok 9 dk; en çok 4 süreç aynı anda. Çıktı: <klasör>/<kip>_<bölüm>.log
set -u
GODOT="${GODOT:-$HOME/is/godot/godot}"
cd "$(dirname "$0")/../.."
out="$1"; kip="$2"; shift 2
mkdir -p "$out"
extra="--ayak-olc"
[ "$kip" = "once" ] && extra="$extra --ayak-ik=0"
for c in "$@"; do
  ch="${c%%:*}"; v=""; [ "$c" != "$ch" ] && v="=${c#*:}"
  timeout 540 "$GODOT" --headless --max-fps 20 --path . -- --chapter="$ch" --autotest"$v" $extra > "$out/${kip}_${c/:/_}.log" 2>&1 &
done
wait
