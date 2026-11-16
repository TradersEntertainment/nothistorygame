#!/bin/bash
# kare.sh <cikti_dizini> <godot argümanları...> — ekranlı (xvfb, yazılımsal GL) kare/bütçe koşusu
out="$1"; shift
mkdir -p "$out"
cd "${PROJ:-/home/user/nothistorygame}"
timeout ${KT:-590} xvfb-run -a -s "-screen 0 1280x720x24" ~/is/godot/godot --path . --rendering-driver opengl3 --resolution 1280x720 -- "$@" --dialogshots="$out" > "$out.log" 2>&1
echo "KARE_BITTI rc=$? $*" >> "$out.log"
