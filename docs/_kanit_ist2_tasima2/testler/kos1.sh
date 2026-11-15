#!/bin/bash
# Tek koşu: kos1.sh <cikti_adi> <godot argümanları...>   (çıktı ~/is/out/<ad>.txt, sonunda KOSU satırı)
ad="$1"; shift
mkdir -p ~/is/out
cd "${KOK:-/home/user/nothistorygame}" || exit 1
t0=$(date +%s)
timeout 300 ~/is/godot/godot --headless --max-fps 20 --path . -- "$@" > ~/is/out/"$ad".txt 2>&1
rc=$?
echo "KOSU ad=$ad rc=$rc sn=$(( $(date +%s) - t0 )) args=$*" >> ~/is/out/"$ad".txt
