#!/bin/bash
# pafta.sh AD [fps=4] : kayıttaki her MONTAGE penceresinden kare paftası
S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad
F=$S/fragman2; AD=$1; FPS=${2:-4}
python3 - "$F/kayit/$AD.log" <<'PY' > $F/kare/$AD.segs
import re,sys
cur=None
for l in open(sys.argv[1],errors='replace'):
    m=re.search(r"MONTAGE (in|out) seg=(\d+) frame=(\d+)",l)
    if not m: continue
    if m.group(1)=='in': cur=(m.group(2),int(m.group(3)))
    elif cur: print(cur[0],cur[1],int(m.group(3))); cur=None
PY
while read SEG A B; do
  T0=$(python3 -c "print($A/30)"); D=$(python3 -c "print(($B-$A)/30)")
  ffmpeg -v error -y -ss $T0 -t $D -i $F/kayit/$AD.avi -vf "fps=$FPS,scale=480:-1,drawtext=text='%{pts\:hms}':x=4:y=4:fontsize=14:fontcolor=yellow:box=1:boxcolor=black,tile=6x8" $F/kare/${AD}_s${SEG}_%02d.jpg
  echo "seg $SEG: $A-$B ($D sn)"; ls $F/kare/${AD}_s${SEG}_*.jpg
done < $F/kare/$AD.segs
