#!/bin/bash
# kaydet.sh AD COZUNURLUK [godot argümanları...]   ör: kaydet.sh p_buro 640x360 only=0
S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad
F=$S/fragman2
AD=$1; RES=$2; shift 2
W=${RES%x*}; H=${RES#*x}
cd /home/user/nothistorygame
if pgrep -f "trailer/gameplay.tscn" >/dev/null; then echo "BAŞKA GODOT ÇALIŞIYOR"; pgrep -af "trailer/gameplay.tscn"; exit 3; fi
START=$(date +%s)
timeout ${TMO:-5400} xvfb-run -a -s "-screen 0 ${W}x${H}x24" $S/godot/godot --path . --write-movie $F/kayit/$AD.avi --fixed-fps 30 \
  --resolution $RES res://tools/trailer/gameplay.tscn -- set=${SET:-story} "$@" > $F/kayit/$AD.log 2>&1
echo "çıkış=$? süre=$(( $(date +%s) - START ))sn"
grep -E "MONTAGE (seg|in|out|done)|SCRIPT ERROR|ERROR" $F/kayit/$AD.log | head -40
