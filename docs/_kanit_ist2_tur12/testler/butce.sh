#!/bin/bash
# butce.sh <cikti_onek> <bekle_sn> <bolum argümanları...> — SONRA (depo) ve ÖNCE (~/is/once) AYNI ANDA, --autotest YOK:
# oyuncu doğuş noktasında, kamera iki koşuda aynı (poz satırıyla doğrulanır). T12KARE=1 ise SONRA'nın kareleri.
out="$1"; bk="$2"; shift 2
mkdir -p "$(dirname "$out")"
( cd /home/user/nothistorygame && timeout 400 xvfb-run -a -s "-screen 0 1280x720x24" ~/is/godot/godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur12_butce.tscn -- "$@" --t12bekle=$bk --t12kam=$out.kam_sonra.json ${T12KARE:+--t12kare=$out.kare} > $out.sonra.ham 2>&1 ) &
( cd /root/is/once && timeout 400 xvfb-run -a -s "-screen 0 1280x720x24" ~/is/godot/godot --path . --rendering-driver opengl3 --resolution 1280x720 res://tests/_ist/tur12_butce.tscn -- "$@" --t12bekle=$bk --t12kam=$out.kam_once.json > $out.once.ham 2>&1 ) &
wait
grep -h "T12\|SCRIPT ERROR" $out.sonra.ham | sed 's/^/SONRA /' > $out.txt
grep -h "T12\|SCRIPT ERROR" $out.once.ham | sed 's/^/ONCE /' >> $out.txt
