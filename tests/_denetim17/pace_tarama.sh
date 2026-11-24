#!/usr/bin/env bash
# G17 DONUKAUDIT taraması (paket DIŞI): her bölümün varsayılan yolu gerçek hızda (PACE=1) oynar; oyuncunun meşru bir
# sebep olmadan (replik, seçim, kararma, sinematik, betik yürüyüşü, mini oyun yok) > 4 sn donuk beklediği yerler.
# Kullanım: GODOT=~/is/godot/godot bash tests/_denetim17/pace_tarama.sh [PARÇA PARÇALAR] > cikti.txt
# Her bölüm en çok 15 dakika. Çıktı: "PACETARAMA <bölüm> sure=<sn> donuk=<n> pass=<0/1>" ve DONUKAUDIT satırları.
set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/../.."
K="${1:-0}"
N="${2:-1}"
i=0
for ch in 0 1 2 3 4 5 6 7 8 8y 9 10 11 12 13 10b 10z 10g 10a 10l 16 10h 12b 14 15 17 18 18b 19 20 21 22 23 24 25 26 \
		17o 19o 20o 21o 22o 24o 26o 36b 42b 41o 44b 43o 28o 29 30 30o 32o 37o 38o 39o 31o 33o 34o 35o 29o 27; do
	i=$((i + 1))
	[ $((i % N)) -eq "$K" ] || continue
	t0=$(date +%s)
	out=$(PACE=1 timeout 900 "$GODOT" --headless --max-fps 30 --path . -- --chapter=$ch --autotest 2>&1)
	rc=$?
	t1=$(date +%s)
	d=$(echo "$out" | grep -c "^DONUKAUDIT")
	p=0; echo "$out" | grep -q "AUTOTEST PASS" && p=1
	echo "PACETARAMA $ch sure=$((t1 - t0)) donuk=$d pass=$p rc=$rc"
	echo "$out" | grep -E "^DONUKAUDIT|SCRIPT ERROR" | awk '!seen[$0]++' | sed "s/^/  [$ch] /"
done
