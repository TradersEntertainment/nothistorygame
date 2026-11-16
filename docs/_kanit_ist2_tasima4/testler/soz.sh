#!/bin/bash
# soz.sh: sözleşme üçlüsü (sırayla)
cd /home/user/nothistorygame
for s in sur_sozlesme sur_oyun_denetim sur_oyun_yuru; do
  timeout 600 ~/is/godot/godot --headless --max-fps 20 --path . tests/_ist/$s.tscn > ~/is/t/soz/$s.ham 2>&1
  grep -E "SURSOZLESME|SUROYUN|WALKTHRU OZET|SCRIPT ERROR" ~/is/t/soz/$s.ham | tail -3
done
