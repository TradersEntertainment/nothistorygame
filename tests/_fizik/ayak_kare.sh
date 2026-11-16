#!/usr/bin/env bash
# Fizik-ayak oyun içi kareler: ayak_kare.sh <çıktı> <bölüm[:çeşit]> <ek argümanlar...>
# ÖNCE (--ayak-ik=0) ve SONRA aynı anda, pencereli (xvfb, 1280x720, opengl3), en çok 9,5 dk.
set -u
GODOT="${GODOT:-$HOME/is/godot/godot}"
cd "$(dirname "$0")/../.."
out="$1"; c="$2"; shift 2
ch="${c%%:*}"; v=""; [ "$c" != "$ch" ] && v="=${c#*:}"
for m in once sonra; do
  a=""; [ "$m" = once ] && a="--ayak-ik=0"
  d="$out/${c/:/_}_$m"; mkdir -p "$d"
  timeout 570 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --rendering-driver opengl3 --resolution 1280x720 \
    -- --chapter="$ch" --autotest"$v" --shots="$d" --ayak-kare="$d" $a "$@" > "$d.log" 2>&1 &
done
wait
