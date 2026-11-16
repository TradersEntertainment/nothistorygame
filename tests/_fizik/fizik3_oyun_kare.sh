#!/usr/bin/env bash
# Fizik-3 oyun içi kumaş kareleri: fizik3_oyun_kare.sh <çıktı> <bölüm[:çeşit]> <saniyeler (12,30,…)> [kim] [ek argümanlar…]
# Pencereli (xvfb, 1280x720, opengl3), en çok 9,5 dk. KUMAS=0 ile --kumas=0 (ÖNCE).
set -u
GODOT="${GODOT:-$HOME/is/godot/godot}"
cd "$(dirname "$0")/../.."
out="$1"; c="$2"; ts="$3"; kim="${4:-}"; shift 4 2>/dev/null || shift $#
ch="${c%%:*}"; v=""; [ "$c" != "$ch" ] && v="=${c#*:}"
a=""; [ "${KUMAS:-1}" = "0" ] && a="--kumas=0"
d="$out/${c/:/_}"; mkdir -p "$d"
timeout 570 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --rendering-driver opengl3 --resolution 1280x720 \
  -- --chapter="$ch" --autotest"$v" --fizik3-oyun="$d" --fizik3-oyun-t="$ts" ${kim:+--fizik3-oyun-kim=$kim} $a "$@" > "$d.log" 2>&1
