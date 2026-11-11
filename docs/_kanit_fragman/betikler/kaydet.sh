#!/bin/bash
# kaydet.sh AD COZUNURLUK [godot argümanları...]
F=/tmp/fragman2
AD=$1; RES=$2; shift 2
W=${RES%x*}; H=${RES#*x}
cd /home/user/nothistorygame
if pgrep -f "trailer/gameplay.tscn" >/dev/null; then echo "BAŞKA GODOT ÇALIŞIYOR"; exit 3; fi
START=$(date +%s)
timeout ${TMO:-3600} xvfb-run -a -s "-screen 0 ${W}x${H}x24" $F/godot/godot --path . --write-movie $F/kayit/$AD.avi --fixed-fps 30 \
  --resolution $RES res://tools/trailer/gameplay.tscn -- set=${SET:-story} "$@" > $F/kayit/$AD.log 2>&1
echo "çıkış=$? süre=$(( $(date +%s) - START ))sn"
grep -E "MONTAGE (seg|in|out|done)|SCRIPT ERROR" $F/kayit/$AD.log | head -40
