#!/usr/bin/env bash
# Fizik-yığılma oyun içi kareler: yigilma_kare.sh <çıktı> <kip: once|sonra> <bölüm[:çeşit]> [ek argümanlar...]
# Pencereli (xvfb, 1280x720, opengl3), en çok 9,5 dk; yığılmanın 6 anı oyuncu kamerasından (Yigilma.kare).
set -u
GODOT="${GODOT:-$HOME/is/godot/godot}"
cd "$(dirname "$0")/../.."
out="$1"; kip="$2"; c="$3"; shift 3
ch="${c%%:*}"; v=""; [ "$c" != "$ch" ] && v="=${c#*:}"
a=""; [ "$kip" = once ] && a="--yigilma=0"
d="$out/${c/:/_}_$kip"; mkdir -p "$d"
timeout 570 xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --rendering-driver opengl3 --resolution 960x540 \
  -- --chapter="$ch" --autotest"$v" --yig-kare="$d" $a "$@" > "$d.log" 2>&1
